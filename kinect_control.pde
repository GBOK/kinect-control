// Z point

import org.openkinect.freenect.*;
import org.openkinect.processing.*;

Kinect kinect;
DepthProcessor dp;
KinectRecorder kr;
Render3D r;

int num = 5;
int[][] t = new int[num][3];
int damper = 2;

float meter = 200f;

boolean connected = false;

PVector box = new PVector(0.1f, 0.1f, 0.3f);

float angle = 0.0f;

float limit = 2.0f;

void setup() {
    size(1280, 960, P3D);

    kinect = new Kinect(this);
    kinect.initDepth();

    kr = new KinectRecorder();
    dp = new DepthProcessor(kinect.width, kinect.height);
    r = new Render3D(this, kinect.width, kinect.height);
}

void draw() {

    background(0);

    int[] rawDepth = kinect.getRawDepth();
    // measure if plugged in (should give a nice "cathode noise" effect while not hooked in or is glitching)
    boolean plugged = rawDepth[0] + rawDepth[639] + rawDepth[153600] + rawDepth[306560] + rawDepth[307199] > 0;

    // override
    if (!plugged) {
        rawDepth = kr.getRaw();
    }

    // this is for recorder. should go away
    kr.sample(rawDepth);
    PImage image = kr.getImage(rawDepth);
    // end recorder stuff

    dp.setRawData(rawDepth); // process

    pushMatrix(); // center and rotate
    translate(width / 2, height / 2, 0);
    rotateY(mouseX * TAU / width - PI);

    r.draw(dp.getPoints(), meter);

    //PVector p = dp.getTrack(); // get tracked point
    //PVector p = dp.getAverage(); // get tracked point
    //PVector p = dp.getWeighted(); // get tracked point
    ArrayList<PVector> ps = dp.detect(); // get tracked point
    int counter = 0;
    for (PVector p : ps) {
        pushMatrix(); // bannerize
        translate(p.x * meter, p.y * meter, -p.z * meter);
        //rotateY(-(mouseX * TAU / width - PI)); // banner

        //ellipseMode(CENTER);
        pushStyle();
        colorMode(HSB, 100);
        stroke(10 * counter++, 100, 100, 50);
        strokeWeight(2);
        noFill();
        //ellipse(0, 0, 100, 100);

        beginShape(QUAD_STRIP);
        vertex(-box.x * meter , -box.y * meter, 0);
        vertex(-(box.x + box.z * 0.5f) * meter, -(box.y + box.z * 0.5f) * meter, - box.z * meter);
        vertex(-box.x * meter, box.y * meter, 0);
        vertex(-(box.x + box.z * 0.5f) * meter, (box.y + box.z * 0.5f) * meter, - box.z * meter);
        vertex(box.x * meter, box.y * meter, 0);
        vertex((box.x + box.z * 0.5f) * meter, (box.y + box.z * 0.5f) * meter, - box.z * meter);
        vertex(box.x * meter, -box.y * meter, 0);
        vertex((box.x + box.z * 0.5f) * meter, -(box.y + box.z * 0.5f) * meter, - box.z * meter);
        vertex(-box.x * meter, -box.y * meter, 0);
        vertex(-(box.x + box.z * 0.5f) * meter, -(box.y + box.z * 0.5f) * meter, - box.z * meter);
        endShape();

        popStyle();
        popMatrix(); // end bannerize
    }



    popMatrix(); // end center and rotate


    fill(255);
    text("ANGLE: " + angle, 10, 20);
    text("KINECT: " + (plugged ? "DETECTED" : "N/A"), 10, 40);
    text("FPS:" + frameRate, 10, 60);
}

// Adjust the angle and the depth threshold min and max
void keyPressed() {
    if (key == CODED) {
        if (keyCode == UP) {
          angle += 1.0f;
        } else if (keyCode == DOWN) {
          angle -= 1.0f;
        }
        angle = constrain(angle, -90, 90);
        //kinect.setTilt(angle);
    } else if (key == 'l') {
        dp.setLimit(limit += 0.1f);
    } else if (key == 'L') {
        dp.setLimit(limit -= 0.1f);
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
