
class Track implements Comparable<Track> {
    private int tick = 0;
    @Override
    public int compareTo(Track t) {
        return this.tick > t.tick ? 1 : (this.tick < t.tick ? -1 : 0);
    }
}
