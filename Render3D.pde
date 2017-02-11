
class Render3D {

    PApplet parent;
    int w, h;
    int[] points;
    int scale = 10;

    Render3D(PApplet parent, int w, int h) {
        this.parent = parent;
        this.w = w;
        this.h = h;
        this.points = new int[w * h];
    }

    void setDepth(int[] depths) {
        this.points = depths;
    }

    void draw(ArrayList<PVector> points, float meter) {
        this.parent.pushStyle();
        this.parent.noFill();
        this.parent.strokeWeight(0.5);
        this.parent.stroke(255);
        int counter = 0;
        for (PVector d : points) {
            if (++counter % this.scale != 0) continue;
            this.parent.point(d.x * meter, d.y * meter, -d.z * meter);

        }
        this.parent.popStyle();
    }

}
