import java.nio.file.*;

class KinectRecorder {
    boolean recording = false;
    boolean replaying = false;

    private int counter = 0;
    private int playhead = 0;
    private String file = null;

    KinectRecorder() {
    }

    KinectRecorder(String file) {
        this.setFile(file);
    }

    void setFile(String file) {
        this.file = file;
    }

    void sample(int[] values) {
        if (!this.recording) return;
        byte[] b = this.convertToBytes(values);
        // disable recording
        //saveBytes(this.filename(this.counter++), this.convertToBytes(values));
    }

    String filename(int counter) {
        return this.file + String.format("%5s", counter).replace(' ', '0');
    }

    byte[] convertToBytes(int[] frame) {
        byte[] bytes = new byte[frame.length * 2];
        for (int i = 0; i < frame.length; i++) {
            bytes[i * 2] = byte(frame[i] % 256 - 128); // modulus
            bytes[i * 2  + 1] = byte(frame[i] / 256); // scale
        }
        return bytes;
    }

    int[] convertToFrame(byte[] bytes) {
        int[] frame = new int[bytes.length / 2];
        for (int i = 0; i < frame.length; i++) {
            frame[i] = bytes[i * 2] + 128 + bytes[i * 2 + 1] * 256;
        }
        return frame;
    }

    PImage getImage(int[] rawDepth) {
        PImage img = new PImage(640, 480, RGB);
        img.loadPixels();
        for (int i = 0; i < rawDepth.length; i++) {
            img.pixels[i] = color(255 - rawDepth[i] * 0xff / 2047);
        }
        img.updatePixels();
        return img;
    }

    int[] getRaw() {
        if (replaying) {
            File f = new File(sketchPath(this.filename(this.playhead)));
            if (!f.isFile()){
                playhead = 0;
                f = new File(sketchPath(this.filename(this.playhead)));
            }
            if (f.isFile()) {
                byte[] bytes = loadBytes(this.filename(this.playhead++));
                return convertToFrame(bytes);
            }
        }
        // default to noise
        int[] frame = new int[640 * 480];
        for (int i = 0; i < 640 * 480; i++) {
            frame[i] = int(random(0, 2048));
        }
        return frame;
    }

    void startRecording() {
        recording = true;
    }

    void stopRecording() {
        recording = false;
    }

    void startReplaying() {
        replaying = true;
    }

    void stopReplaying() {
        replaying = false;
    }

    void startStopReplaying() {
        replaying = !replaying;
    }
}