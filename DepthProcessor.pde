import java.util.Collections;
import shapes3d.utils.*;

// depth processing class

class DepthProcessor {

    private int w, h;
    private ArrayList<V> points;
    private float[] lookup;
    private PVector track;
    private float limit;
    private int samplerate;
    private int max;

    DepthProcessor(int w, int h, int samplerate, float limit, int max) {
        this.w = w;
        this.h = h;
        this.points = new ArrayList<V>(this.w * this.h);
        this.generateLookupTable();
        this.samplerate = samplerate;
        this.limit = limit;
        this.max = max;
    }

    DepthProcessor(int w, int h, int samplerate, float limit) {
        this(w, h, samplerate, limit, 10);
    }

    DepthProcessor(int w, int h, int samplerate) {
        this(w, h, samplerate, 1000.0f);
    }

    DepthProcessor(int w, int h) {
        this(w, h, 3);
    }

    public void setLimit(float limit) {
        this.limit = limit;
    }

    public void setSamplerate(int samplerate) {
        this.samplerate = samplerate;
    }

    public void setMax(int max) {
        this.max = max;
    }

    public void generateLookupTable() {
        this.lookup = new float[2048];
        for (int i = 0; i < 2048; ++i) {
            this.lookup[i] = this.rawDepthToMeters(i);
        }
    }

    public void setRawData(int[] rawData) {
        Rot rot = new Rot(new PVector(1,0,0), radians(angle));
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
                if (v == null || v.z > this.limit) continue;
                this.points.add(v);
                rot.applyTo((PVector)v);
            }
        }
    }

    public ArrayList<PVector> detect() {
        // sort by depth
        Collections.sort(this.points);
        return this.getBlock();
    }

    public ArrayList<PVector> getBlock() {

        ArrayList<Tracker> trackers = new ArrayList<Tracker>(this.max);

        for (V v : this.points) {

            boolean skip = false;

            outer:
            for(Tracker t : trackers) {

                switch (t.relation(v)) {
                    case 1:
                        skip = true;
                        break;
                    case 2:
                        t.invalidate();
                        skip = true;
                        break;
                    default:
                        // don't care
                }

            }
            if (!skip && trackers.size() < this.max) {
                trackers.add(new Tracker(v, box));
            }

        }

        ArrayList<PVector> output = new ArrayList<PVector>(trackers.size());
        for (Tracker tracker : trackers) {
            if (tracker.isValid())
                output.add((PVector)tracker.tip);
        }
        return output;
    }

    public ArrayList<PVector> getPoints() {
        return new ArrayList<PVector>(this.points);
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
