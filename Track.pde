
class Track implements Comparable<Track> {

    public V tip;
    public PVector dimesions;
    private boolean valid = true;
    public int weight = 0;

    Track(V tip, PVector dimesions){
        this.tip = tip;
        this.dimesions = dimesions;
    }

    public int relation(V v) {

        float dx = abs(v.x - this.tip.x);
        float dy = abs(v.y - this.tip.y);
        float dz = abs(v.z - this.tip.z);

        boolean insidex = dx - dz * 0.5f <= this.dimesions.x;
        boolean insidey = dy - dz * 0.5f <= this.dimesions.y;

        ++ this.weight;
        if (insidex && insidey) return 1;

        if (dz <= this.dimesions.z) {
            float ox = this.dimesions.x + this.dimesions.z * 0.5f;
            float oy = this.dimesions.y + this.dimesions.z * 0.5f;
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
        return this.valid && this.weight > 10;
    }

    @Override
    public int compareTo(Track t) {
        return this.weight > t.weight ? 1 : (this.weight < t.weight ? -1 : 0);
    }
}
