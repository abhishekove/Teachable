# Teachable

It is a package to work with google teachable machine in flutter using inappwebview. It helps developers to make posenet classifier

## Mandatory Section

### HTML for teachable machine
Store this code in html file in your assets directory
```<html>
<div><canvas id="canvas"
        style="position:fixed;min-height:100%;min-width:100%;height:100%;width:100%;top:0%;left:0%;resize:none;"></canvas>
</div>
<script src="https://cdn.jsdelivr.net/npm/@tensorflow/tfjs@1.3.1/dist/tf.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@teachablemachine/pose@0.8/dist/teachablemachine-pose.min.js"></script>
<script type="text/javascript">
    const URL = "Your URL comes here";
    let model, webcam, ctx, labelContainer, maxPredictions;

    async function init() {
        const modelURL = URL + "model.json";
        const metadataURL = URL + "metadata.json";
        model = await tmPose.load(modelURL, metadataURL);

        maxPredictions = model.getTotalClasses();

        // Convenience function to setup a webcam
        const size = 600;
        const flip = true; // whether to flip the webcam
        webcam = new tmPose.Webcam(size, size, flip); // width, height, flip
        await webcam.setup(); // request access to the webcam
        await webcam.play();
        window.requestAnimationFrame(loop);

        // append/get elements to the DOM
        const canvas = document.getElementById("canvas");
        canvas.width = size; canvas.height = size;
        ctx = canvas.getContext("2d");
    }

    async function loop(timestamp) {
        webcam.update(); // update the webcam frame
        await predict();
        window.requestAnimationFrame(loop);
    }

    async function predict() {
        // Prediction #1: run input through posenet
        // estimatePose can take in an image, video or canvas html element
        const { pose, posenetOutput } = await model.estimatePose(webcam.canvas);
        // Prediction 2: run input through teachable machine classification model
        const prediction = await model.predict(posenetOutput);

        let ans = 0, score = 0;
        for (let i = 0; i < maxPredictions; i++) {
            if (prediction[i].probability.toFixed(2) > score) {
                score = prediction[i].probability.toFixed(2);
                ans = prediction[i].className;
            }
        }

        // finally draw the poses
        drawPose(pose);

        try {
            // Code to run
            //  updater(ans,score);
            window.flutter_inappwebview.callHandler('updater', prediction);
            //  [break;]
        }

        catch (e) {
            // Code to run if an exception occurs
            //  [break;]
        }
    }

    function drawPose(pose) {
        if (webcam.canvas) {
            ctx.drawImage(webcam.canvas, 0, 0);
            // draw the keypoints and skeleton
            if (pose) {
                const minPartConfidence = 0.5;
                tmPose.drawKeypoints(pose.keypoints, minPartConfidence, ctx);
                tmPose.drawSkeleton(pose.keypoints, minPartConfidence, ctx);
            }
        }
    }
    init();
</script>

</html>
```
### Flutter Section
```
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Add permissions using permission_handler plugin
  await Permission.camera.request();
  await Permission.microphone.request();
  runApp(MyApp());
}
```
[Permission Handler Plugin](https://pub.dev/packages/permission_handler "Permission Handler Plugin title")

### Use of teachable widget
```
Teachable(
    path: "Path to your html file",
    results: (res) {
        // Recieve JSON data here

        // Convert json to usable format
        var resp = jsonDecode(res); 
        print("The values are $resp");
    },
)
```
## Permissions

### Android
```
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.VIDEO_CAPTURE" />
<uses-permission android:name="android.permission.AUDIO_CAPTURE" />
```
### IOS

https://inappwebview.dev/docs/get-started/setup-ios/ 

https://inappwebview.dev/docs/webrtc-api/ (Make changes only in info.plist)

## Training Models
Train your model on [Teachable Machine](https://teachablemachine.withgoogle.com/ "Teachable Machine title") and add your url in your url section.

## Demo
[![SC2 Video](example/intro.gif)](https://youtu.be/cRt43pTVZ84)

## Tutorial 
https://youtu.be/cRt43pTVZ84