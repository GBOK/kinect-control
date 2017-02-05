import java.util.Collections;
import shapes3d.utils.*;

// depth processing class

class DepthProcessor {

    private int w, h;
    private ArrayList<V> points;
    private float[] lookup;
    private PVector track;

    DepthProcessor(int w, int h) {
        this.w = w;
        this.h = h;
        this.points = new ArrayList<V>(this.w * this.h);
        this.generateLookupTable();
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
        for (int i = 0, n = this.w * this.h; i < n; ++i) {
            V v = this.depthToWorld(i % this.w, i / this.w, rawData[i]);
            if (v == null) continue;
            rot.applyTo((PVector)v);
            this.points.add(v);
        }
    }

    public ArrayList<PVector> detect() {
        // sort by depth
        Collections.sort(this.points);
        return this.getBlock();
    }

    public ArrayList<PVector> getBlock() {

        ArrayList<Tracker> trackers = new ArrayList<Tracker>(50);

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
            if (!skip && trackers.size() < 50) {
                trackers.add(new Tracker(v, box));
            }

        }

        ArrayList<PVector> output = new ArrayList<PVector>(trackers.size());
        for (Tracker tracker : trackers) {
            if (tracker.isValid())
                output.add((PVector)tracker.tip);
        }
        return output;
        // return (PVector)trackers.get(0).tip;
        // for(Tracker t : trackers) {
        //     if (!t.tainted && t.weight > 10) return (PVector)(t.tip);
        // }

        // return null;
    }

    public PVector getCone() {

        int errors = 0; // current errors
        int errlimit = 50; // max errors

        float dlimit = 0.4f; // one meter

        // sort by depth
        Collections.sort(this.points);

        V tip = null;
        for (V v : this.points){
            if (tip == null) {
                tip = v;
                continue;
            }

            // distace in depth
            float dz = v.z - tip.z;

            // distance in xy
            float dxy = dist(v.x, v.y, tip.x, tip.y);

            if (dz < dlimit) {
                if (dz + 0.1f > dxy){
                    continue;
                } else if (++errors >= errlimit){
                    tip = null;
                }
            } else {
                break;
            }
        }

        return tip != null ? new PVector(tip.x, tip.y, tip.z) : null;
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
        //double depth = this.lookup[depthValue]; // this should be a lookup table
        result.x = (float)((x - cx_d) * depth * fx_d);
        result.y = (float)((y - cy_d) * depth * fy_d);
        result.z = (float)(depth);
        return result;
    }
}

class V extends PVector implements Comparable<V> {

    @Override
    public int compareTo(V d) {
        return this.z > d.z ? 1 : (this.z < d.z ? -1 : 0);
    }
}

class Tracker implements Comparable<Tracker> {

    public V tip;
    public PVector box;
    private boolean valid = true;
    public int weight = 0;

    Tracker(V tip, PVector box){
        this.tip = tip;
        this.box = box;
    }

    public int relation(V v) {

        float dx = abs(v.x - this.tip.x);
        float dy = abs(v.y - this.tip.y);
        float dz = abs(v.z - this.tip.z);

        boolean insidex = dx - dz * 0.5f <= this.box.x;
        boolean insidey = dy - dz * 0.5f <= this.box.y;

        if (insidex && insidey) return 1;

        if (dz <= this.box.z) {
            float ox = this.box.x + this.box.z * 0.5f;
            float oy = this.box.y + this.box.z * 0.5f;
            if (dx <= ox && dy <= oy) return 2;
        }

        return 0;
    }

    public boolean close(V v) {
        float dx = abs(v.x - this.tip.x);
        float dy = abs(v.y - this.tip.y);
        float dz = abs(v.z - this.tip.z);

        return dist(0.0f, 0.0f, 0.0f, dx, dy, dz) < this.tip.z;
    }

    public void invalidate() {
        this.valid = false;
    }

    public boolean isValid() {
        return this.valid;
    }

    @Override
    public int compareTo(Tracker t) {
        return this.weight > t.weight ? 1 : (this.weight < t.weight ? -1 : 0);
        //return this.tip.z > t.tip.z ? 1 : (this.tip.z < t.tip.z ? -1 : 0);
    }
}

class Track implements Comparable<Track> {
    private int tick = 0;
    @Override
    public int compareTo(Track t) {
        return this.tick > t.tick ? 1 : (this.tick < t.tick ? -1 : 0);
    }
}