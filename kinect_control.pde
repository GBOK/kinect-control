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

float limit = 2.0f;

String setting = "";

void setup() {
    size(1280, 960, P3D);
    pixelDensity(2);

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
    rotateX(-mouseY * TAU / height - PI);

    r.draw(dp.getPoints(), meter);



    //PVector p = dp.getTrack(); // get tracked point
    //PVector p = dp.getAverage(); // get tracked point
    //PVector p = dp.getWeighted(); // get tracked point
    ArrayList<Tracker> ts = dp.detect(); // get tracked point
    int counter = 0;
    for (Tracker t : ts) {
        pushStyle();
        colorMode(HSB, 100);
        stroke(t.c);
        strokeWeight(0.5);
        noFill();
        PVector p = t.getLast();
        pushMatrix(); // bannerize
        translate(p.x * meter, p.y * meter, -p.z * meter);
        //rotateY(-(mouseX * TAU / width - PI)); // banner
        //ellipseMode(CENTER);
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
        popMatrix(); // end bannerize

        strokeWeight(10);
        beginShape();
        for (PVector h : t.history) {
            vertex(h.x * meter, h.y * meter, -h.z * meter);
        }
        endShape();

        popStyle();

    }


    popMatrix(); // end center and rotate


    fill(255);
    text("ANGLE: X: " + dp.getAngleXDeg() + " Y: " + dp.getAngleYDeg(), 10, 20);
    text("KINECT: " + (plugged ? "DETECTED" : "N/A"), 10, 40);
    text("FPS:" + frameRate, 10, 60);
    text("TRACKERS:" + ts.size(), 10, 80);
}

// Adjust the angle and the depth threshold min and max
void keyPressed() {
    float box = 20;
    if (key == CODED) {

        float add = 0;
        if (keyCode == UP || keyCode == LEFT) {
            add = -1.0f;
        } else if (keyCode == DOWN || keyCode == RIGHT) {
            add = 1.0f;
        }
        switch (setting) {
            case "left":
                dp.setLeft(dp.getLeft() + add);
                break;
            case "right":
                dp.setRight(dp.getRight() + add);
                break;
            case "top":
                dp.setTop(dp.getTop() + add);
                break;
            case "bottom":
                dp.setBottom(dp.getBottom() + add);
                break;
            case "front":
                dp.setFront(dp.getFront() + add);
                break;
            case "back":
                dp.setBack(dp.getBack() + add);
                break;
            case "angle x":
                dp.setAngleXDeg(dp.getAngleXDeg() + add);
                break;
            case "angle y":
                dp.setAngleYDeg(dp.getAngleYDeg() + add);
                break;
            default:
        }
        println(dp.getLeft());
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
    } else if (key == 'a') {
        setting = "left";
    } else if (key == 'd') {
        setting = "right";
    } else if (key == 'w') {
        setting = "top";
    } else if (key == 's') {
        setting = "bottom";
    } else if (key == 'f') {
        setting = "front";
    } else if (key == 'b') {
        setting = "back";
    } else if (key == 'x') {
        setting = "angle x";
    } else if (key == 'y') {
        setting = "angle y";
    }
    //dp.setBox(-box, -box, -box, box, box, box);
}
