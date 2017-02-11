import java.util.*;
import shapes3d.utils.*;

/**
 *
 */
class DepthProcessor {

    private int w, h;
    private ArrayList<V> points;
    private float[] lookup;
    private int samplerate;
    private float sensitivity;
    private int max;
    private float angleX = 0.0f, angleY = 0.0f;
    private PVector negative = new PVector(-10.0f, -10.0f, -10.0f);
    private PVector positive = new PVector(10.0f, 10.0f, 10.0f);
    private ArrayList<Tracker> trackers = new ArrayList<Tracker>(10);

    DepthProcessor(int w, int h, int samplerate, float sensitivity, int max) {
        this.w = w;
        this.h = h;
        this.points = new ArrayList<V>(this.w * this.h);
        this.generateLookupTable();
        this.samplerate = samplerate;
        this.sensitivity = sensitivity;
        this.max = max;
    }

    DepthProcessor(int w, int h, int samplerate, float sensitivity) {
        this(w, h, samplerate, sensitivity, 10);
    }

    DepthProcessor(int w, int h, int samplerate) {
        this(w, h, samplerate, 0.2f);
    }

    DepthProcessor(int w, int h) {
        this(w, h, 3);
    }

    public void setBox(float nx, float ny, float nz, float px, float py, float pz) {
        this.negative.set(nx, ny, nz);
        this.positive.set(px, py, pz);
    }

    public void setLeft(float nx) {
        this.negative.x = nx;
    }

    public void setRight(float px) {
        this.positive.x = px;
    }

    public void setTop(float ny) {
        this.negative.y = ny;
    }

    public void setBottom(float py) {
        this.positive.y = py;
    }

    public void setFront(float nz) {
        this.negative.z = nz;
    }

    public void setBack(float pz) {
        this.positive.z = pz;
    }

    public float getLeft() {
        return this.negative.x;
    }

    public float getRight() {
        return this.positive.x;
    }

    public float getTop() {
        return this.negative.y;
    }

    public float getBottom() {
        return this.positive.y;
    }

    public float getFront() {
        return this.negative.z;
    }

    public float getBack() {
        return this.positive.z;
    }

    public void setAngleX(float angleX) {
        this.angleX = angleX;
    }

    public void setAngleY(float angleY) {
        this.angleY = angleY;
    }

    public float getAngleX() {
        return this.angleX;
    }

    public float getAngleY() {
        return this.angleY;
    }

    public void setAngleXDeg(float angleXDeg) {
        this.setAngleX(angleXDeg * PI / 180.0f);
    }

    public void setAngleYDeg(float angleYDeg) {
        this.setAngleY(angleYDeg * PI / 180.0f);
    }

    public float getAngleXDeg() {
        return this.getAngleX() * 180.0f / PI;
    }

    public float getAngleYDeg() {
        return this.getAngleY() * 180.0f / PI;
    }

    public void setSamplerate(int samplerate) {
        this.samplerate = samplerate;
    }

    public void setMax(int max) {
        this.max = max;
    }

    public void setRawData(int[] rawData) {
        Rot rotX = new Rot(new PVector(1, 0, 0), this.angleX);
        Rot rotY = new Rot(new PVector(0, 1, 0), this.angleY);
        this.points.clear();
        for (int y = 0; y < this.h; y += samplerate) {
            for (int x = 0; x < this.w; x += samplerate) {
                long d = 0;
                int size = (int)pow(2, (samplerate - 1) * 2);
                int side = (int)pow(2, samplerate - 1);
                for (int s = 0; s < size; s++) {
                    int sx = s % side;
                    int sy = s / side;
                    d += rawData[x + y * this.w];
                }
                d /= size;
                V v = this.depthToWorld(x, y, (int)d);
                if (v == null) continue;
                rotY.applyTo((PVector)v);
                rotX.applyTo((PVector)v);
                if (v.x < this.negative.x ||
                    v.y < this.negative.y ||
                    v.z < this.negative.z ||
                    v.x > this.positive.x ||
                    v.y > this.positive.y ||
                    v.z > this.positive.z)
                    continue;
                this.points.add(v);
            }
        }
    }

    public ArrayList<Tracker> detect() {
        Collections.sort(this.points); // sort by depth
        ArrayList<Track> tracks = new ArrayList<Track>(this.max);
        for (V v : this.points) {
            boolean skip = false;
            outer:
            for(Track t : tracks) {
                switch (t.relation(v)) {
                    case 1:
                        skip = true;
                        break;
                    case 2:
                        t.invalidate();
                        skip = true;
                        break;
                    default:
                        // don't care. skip
                }
            }
            if (!skip && tracks.size() < this.max) {
                tracks.add(new Track(v, box));
            }
        }
        for (Track track : tracks) {
            if (track.isValid()) {
                for (Tracker tracker : this.trackers) {
                    if (tracker.claim(track.tip)) {
                        track = null;
                        break;
                    }
                }
                if (track != null) {
                    this.trackers.add(new Tracker(track.tip, this.sensitivity));
                }
            }
        }
        ArrayList<Tracker> output = new ArrayList<Tracker>(this.trackers.size());
        Iterator<Tracker> itr = this.trackers.iterator();
        while (itr.hasNext()) {
            Tracker tr = itr.next();
            if (tr.prune()) {
                itr.remove();
            } else {
                if (tr.isVisible()) {
                    output.add(tr);
                }
            }
        }
        return this.trackers;
    }

    public ArrayList<PVector> getPoints() {
        return new ArrayList<PVector>(this.points);
    }

    private void generateLookupTable() {
        this.lookup = new float[2048];
        for (int i = 0; i < 2048; ++i) {
            this.lookup[i] = this.rawDepthToMeters(i);
        }
    }

    // These functions come from: http://graphics.stanford.edu/~mdfisher/Kinect.html
    private float rawDepthToMeters(int depthValue) {
        float out = (float)(1.0 / ((double)(depthValue) * -0.0030711016 + 3.3309495161));
        if (depthValue == 2047 || out < 0.0f) {
            out = -1.0f;
        }
        return out;
    }

    private V depthToWorld(int x, int y, int depthValue) {
        double depth = this.lookup[depthValue];
        if (depth < 0.0f) return null;
        final double fx_d = 1.0 / 5.9421434211923247e+02;
        final double fy_d = 1.0 / 5.9104053696870778e+02;
        final double cx_d = 3.3930780975300314e+02;
        final double cy_d = 2.4273913761751615e+02;
        V result = new V();
        result.x = (float)((x - cx_d) * depth * fx_d);
        result.y = (float)((y - cy_d) * depth * fy_d);
        result.z = (float)(depth);
        return result;
    }
}
