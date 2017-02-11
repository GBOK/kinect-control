

class Tracker implements Comparable<Tracker> {

    public ArrayList<PVector> history;
    private float distance;
    private int threshold;
    private int tick = 0;
    public color c;

    Tracker(V initial, float distance, int threshold) {
        this.history = new ArrayList<PVector>(100);
        this.claim(initial);
        this.distance = distance;
        this.threshold = threshold;
        pushStyle();
        colorMode(HSB, 100);
        this.c = color(random(0, 100), 100, 100, 50);
        popStyle();
    }

    Tracker(V initial, float distance) {
        this(initial, distance, 2);
    }

    Tracker(V initial) {
        this(initial, 0.3f);
    }

    Tracker() {
        this(null);
    }

    public boolean prune() {
        if (++this.tick > this.history.size() + this.threshold) {
            return true;
        }
        return false;
    }

    public boolean isVisible() {
        return this.history.size() > this.threshold;
    }

    public PVector getLast() {
        return ! this.history.isEmpty()
            ? this.history.get(this.history.size() - 1)
            : null;
    }

    public boolean claim(V point) {
        PVector last = ! this.history.isEmpty()
            ? this.history.get(this.history.size() - 1)
            : null;

        if (last == null || dist(last.x, last.y, last.z, point.x, point.y, point.z) < this.distance){
            this.history.add((PVector)point);
            return true;
        }
        return false;
    }

    @Override
    public int compareTo(Tracker t) {
        return this.tick > t.tick ? 1 : (this.tick < t.tick ? -1 : 0);
    }
}
