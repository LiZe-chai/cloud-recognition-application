package app.lize.cloud_recognition

import android.os.Bundle
import android.util.Log

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import org.opencv.android.OpenCVLoader
import org.opencv.core.*
import org.opencv.imgproc.Imgproc

class MainActivity: FlutterActivity() {

    private val CHANNEL = "cloud_opencv"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (!OpenCVLoader.initDebug()) {
            Log.e("OpenCV", "Initialization failed")
        } else {
            Log.d("OpenCV", "OpenCV initialized")
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->

                if (call.method == "processMask") {

                    val args = call.arguments as Map<String, Any>

                    val maskAny = args["mask"]

                    val mask: FloatArray = when (maskAny) {
                        is FloatArray -> maskAny
                        is ArrayList<*> -> maskAny.map { (it as Number).toFloat() }.toFloatArray()
                        else -> throw IllegalArgumentException("Unsupported mask type: ${maskAny?.javaClass}")
                    }

                    val width = args["width"] as Int
                    val height = args["height"] as Int

                    val boxes = processMask(mask, width, height)
                    result.success(boxes)
                }
            }
    }

    private fun processMask(
        mask: FloatArray,
        width: Int,
        height: Int
    ): List<List<Map<String, Int>>> {

        val mat = Mat(height, width, CvType.CV_32F)
        mat.put(0, 0, mask)

        val binary = Mat()
        Imgproc.threshold(mat, binary, 0.5, 1.0, Imgproc.THRESH_BINARY)
        binary.convertTo(binary, CvType.CV_8U, 255.0)

        val contours = mutableListOf<MatOfPoint>()
        val hierarchy = Mat()

        Imgproc.findContours(
            binary,
            contours,
            hierarchy,
            Imgproc.RETR_EXTERNAL,
            Imgproc.CHAIN_APPROX_SIMPLE
        )

        val result = mutableListOf<List<Map<String, Int>>>()

        for (contour in contours) {

            val area = Imgproc.contourArea(contour)

            val points = contour.toArray()

            val contourPoints = points.map {
                mapOf(
                    "x" to it.x.toInt(),
                    "y" to it.y.toInt()
                )
            }

            result.add(contourPoints)
        }

        return result
    }
}