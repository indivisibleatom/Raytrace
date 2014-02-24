class ShapeIntersectionInfo
{
  private Point m_point;
  private Vector m_normal;
  private float m_t;
  private boolean m_fDualSided;
  
  ShapeIntersectionInfo( Point point, Vector normal, float t, boolean fDualSided )
  { 
    m_point = point;
    m_normal = normal;
    m_t = t;
    m_fDualSided = fDualSided;
  }
  
  public Point point() { return m_point; }
  public Vector normal() { return m_normal; }
  public float t() { return m_t; }
  public boolean fDualSided() { return m_fDualSided; }
}

class IntersectionInfo
{
  private LightedPrimitive m_primitive;
  private ShapeIntersectionInfo m_shapeInfo;
  private Color m_diffuse;
  private Color m_ambient;

  
  IntersectionInfo( LightedPrimitive primitive, Color diffuse, Color ambient, ShapeIntersectionInfo info )
  {
    m_primitive = primitive;
    m_shapeInfo = info;
    m_diffuse = diffuse;
    m_ambient = ambient;
    m_diffuse = diffuse;
    m_ambient = ambient;
  }

  public LightedPrimitive primitive() { return m_primitive; }
  public Point point() { return m_shapeInfo.point(); }
  public Vector normal() { return m_shapeInfo.normal(); }
  public float t() { return m_shapeInfo.t(); }
  public boolean fDualSided() { return m_shapeInfo.fDualSided(); }
  public Color diffuse() { return m_diffuse; }
  public Color ambient() { return m_ambient; }
}
