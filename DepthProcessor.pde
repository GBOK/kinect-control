// depth processing class

class DepthProcessor {

    int w, h, max;
    ArrayList<PVector> points;

    DepthProcessor(int w, int h, int points, int max) {
        this.w = w;
        this.h = h;
        this.points = new ArrayList<PVector>();
        this.points.add(new PVector(-1, -1));
        this.max = max;
    }

    DepthProcessor(int w, int h, int points) {
        this(w, h, points, 2047);
    }

    DepthProcessor(int w, int h) {
        this(w, h, 1, 2047);
    }

    void process(int[] raw ) {
        int max = this.max;
        int imax = -1;
        for (int i = 0, n = w * h; i < n; i++) {
            if (raw[i] < max){
                max = raw[i];
                imax = i;
            }
        }
        int x = imax % w;
        int y = imax / w;
        this.points.get(0).lerp(new PVector(x, y), 0.5);

    }

    PVector getPoint(int i) {
        return this.points.get(i);
    }
}