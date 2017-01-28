import java.util.Collections;

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
        this.track = new PVector();
    }

    public void generateLookupTable() {
        this.lookup = new float[2048];
        for (int i = 0; i < 2048; ++i) {
            this.lookup[i] = this.rawDepthToMeters(i);
        }
    }

    public void setRawData(int[] rawData) {
        this.points.clear();
        for (int i = 0, n = this.w * this.h; i < n; ++i) {
            V v = this.depthToWorld(i % this.w, i / this.w, rawData[i]);
            if (v == null) continue;
            this.points.add(v);
        }
    }

    public PVector detect() {
        // sort by depth
        Collections.sort(this.points);
        return this.getBlock();
    }

    public PVector getBlock() {
        int counter = 0;
        PVector inner = new PVector(0.3f, 0.3f, 0.3f);
        PVector outer = new PVector(0.5f, 0.5f);

        ArrayList<V> copy = new ArrayList<V>();
        for (V v : this.points) {
            if (v.z < 1.0f) {
                copy.add(v);
            } else {
                break;
            }
        }


        //println(copy.size());

        while (!copy.isEmpty()) {
            V tip = copy.get(0);

            PVector imin = new PVector(tip.x - inner.x, tip.y - inner.y);
            PVector imax = new PVector(tip.x + inner.x, tip.y + inner.y);

            PVector omin = new PVector(tip.x - outer.x, tip.y - outer.y);
            PVector omax = new PVector(tip.x + outer.x, tip.y + outer.y);

            float depth = tip.z + inner.z;

            // what to drop
            ArrayList<V> toRemove = new ArrayList<V>();
            // measure
            for (V v : copy){
                if (v.z > depth) {
                    //println("found");
                    return tip;
                } else if (imin.x <= v.x && v.x <= imax.x && imin.y <= v.y && v.y <= imax.y) {
                    toRemove.add(v);
                    continue;
                } else if (omin.x <= v.x && v.x <= omax.x && omin.y <= v.y && v.y <= omax.y) {
                    toRemove.add(v);
                    toRemove.add(tip);
                    break;
                }
            }
            copy.removeAll(toRemove);
            if (++counter % 1000 == 0) {
                //println(toRemove.size());
                //println(copy.size());
            }
            //println(toRemove.size());
            //println();

        }

        //println("nothing found");

        return null;
    }

    private int inside(PVector imin, PVector imax, PVector omin, PVector omax, float depth, V v) {
        // finish if we are out of the block scope
        if (v.z > depth) return 0;
        // inner box
        if (imin.x <= v.x && v.x <= imax.x && imin.y <= v.y && v.y <= imax.y) return 1;
        // outer box
        if (omin.x <= v.x && v.x <= omax.x && omin.y <= v.y && v.y <= omax.y) return 2;
        // outside
        return 3;
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
    public boolean skip = false;
    @Override
    public int compareTo(V d) {
        return this.z > d.z ? 1 : (this.z < d.z ? -1 : 0);
    }
}