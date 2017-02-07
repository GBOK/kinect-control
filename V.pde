
class V extends PVector implements Comparable<V> {

    @Override
    public int compareTo(V d) {
        return this.z > d.z ? 1 : (this.z < d.z ? -1 : 0);
    }
}
