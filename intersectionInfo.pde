class ShapeIntersectionInfo
{
  private Point m_point;
  private Vector m_normal;
  private float m_t;
  
  ShapeIntersectionInfo( Point point, Vector normal, float t )
  {
    m_point = point;
    m_normal = normal;
    m_t = t;
  }
  
  public Point point() { return m_point; }
  public Vector normal() { return m_normal; }
  public float t() { return m_t; }
}

class IntersectionInfo
{
  private LightedPrimitive m_primitive;
  private ShapeIntersectionInfo m_shapeInfo;
  
  IntersectionInfo( LightedPrimitive primitive, ShapeIntersectionInfo info )
  {
    m_primitive = primitive;
    m_shapeInfo = info;
  }

  public LightedPrimitive primitive() { return m_primitive; }
  public Point point() { return m_shapeInfo.point(); }
  public Vector normal() { return m_shapeInfo.normal(); }
  public float t() { return m_shapeInfo.t(); }
}
