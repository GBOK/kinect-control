// Z point

import org.openkinect.freenect.*;
import org.openkinect.processing.*;

Kinect kinect;
DepthProcessor dp;
KinectRecorder kr;

int num = 5;
int[][] t = new int[num][3];
int damper = 2;

float angle = 0.0;

boolean connected = false;

void setup() {
    size(640, 480, P3D);

    kinect = new Kinect(this);
    kinect.initDepth();

    kr = new KinectRecorder();
    dp = new DepthProcessor(kinect.width, kinect.height);
}

void draw() {
    pushMatrix();

    int[] rawDepth = kinect.getRawDepth();
    // measure if plugged in (should give a nice "cathode noise" effect while not hooked in or is glitching)
    boolean plugged = rawDepth[0] + rawDepth[639] + rawDepth[153600] + rawDepth[306560] + rawDepth[307199] > 0;
    PImage image;

    // override
    if (!plugged) {
        rawDepth = kr.getRaw();
    }

    kr.sample(rawDepth);
    image = kr.getImage(rawDepth);

    if (image != null){
        image(image, 0, 0);
    }

    dp.process(rawDepth);

    PVector p = dp.getPoint(0);

    ellipseMode(CENTER);
    fill(255);
    noStroke();
    ellipse(p.x, p.y, 10, 10);

    fill(255);
    text("TILT: " + angle, 10, 20);
    text("KINECT: " + (plugged ? "DETECTED" : "N/A"), 10, 40);
    popMatrix();
}

// Adjust the angle and the depth threshold min and max
void keyPressed() {
    if (key == CODED) {
        if (keyCode == UP) {
          angle++;
        } else if (keyCode == DOWN) {
          angle--;
        }
        angle = constrain(angle, 0, 30);
        kinect.setTilt(angle);
    } else if (key == '1') {
        kr.setFile("data/kinect_01/dat");
        kr.startReplaying();
    } else if (key == '2') {
        kr.setFile("data/kinect_02/dat");
        kr.startReplaying();
    } else if (key == '3') {
        kr.setFile("data/kinect_03/dat");
        kr.startReplaying();
    } else if (key == '4') {
        kr.setFile("data/kinect_04/dat");
        kr.startReplaying();
    } else if (key == '5') {
        kr.setFile("data/kinect_05/dat");
        kr.startReplaying();
    } else if (key == ' ') {
        kr.startStopReplaying();
    }
}