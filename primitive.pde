interface Primitive
{
  public LightedPrimitive intersects( Ray ray, float tMin, float tMax ); 
  public IntersectionInfo getIntersectionInfo( Ray ray, float tMin, float tMax );
}

interface LightedPrimitive extends Primitive
{
  public Material getMaterial();
  public Box getBoundingBox();
}

class GeometricPrimitive implements LightedPrimitive
{
  private Shape m_shape;
  private Material m_material;
  
  GeometricPrimitive( Shape shape, Material material )
  {
    m_shape = shape;
    m_material = material;
  }

  public Box getBoundingBox()
  {
    return m_shape.getBoundingBox();
  }
   
  public LightedPrimitive intersects( Ray ray, float tMin, float tMax )
  {
    if ( m_shape.intersects( ray, tMin, tMax ) )
    {
      return this;
    }
    return null;
  }
  
  public IntersectionInfo getIntersectionInfo( Ray ray, float tMin, float tMax )
  {
    ShapeIntersectionInfo shapeInfo =  m_shape.getIntersectionInfo( ray, tMin, tMax );
    if ( shapeInfo == null )
    {
      if (DEBUG && DEBUG_MODE >= VERBOSE)
      {
        print("ShapeInfo is null. This should not happen\n");
      }
      return null;
    }
    return new IntersectionInfo( this, shapeInfo );
  }
  
  public Material getMaterial() { return m_material; }
}

//Stores a reference to the actual primitive and a reference to a transform to take
class InstancePrimitive implements LightedPrimitive
{
  private LightedPrimitive m_primitive;
  private Transformation m_transform;
  private Box m_boundingBox;
  
  InstancePrimitive( LightedPrimitive primitive, Transformation transform )
  {
    m_primitive = primitive;
    m_transform = new Transformation();
    m_transform.clone( transform );
    
    m_boundingBox = new Box( m_primitive.getBoundingBox().extent1(), m_primitive.getBoundingBox().extent2(), m_transform );
  }
  
  public LightedPrimitive intersects( Ray ray, float tMin, float tMax ) 
  {
    Ray rayLocal = m_transform.worldToLocalUnnormalized( ray );
    float scale = 1/rayLocal.getDirection().getMagnitude();
    rayLocal.getDirection().normalize();
    if ( m_primitive.intersects( rayLocal, tMin/scale, tMax/scale ) != null )
    {
      return this;
    }
    return null;
  }
  
  public IntersectionInfo getIntersectionInfo( Ray ray, float tMin, float tMax ) 
  {
    Ray rayLocal = m_transform.worldToLocalUnnormalized( ray );
    float scale = 1/rayLocal.getDirection().getMagnitude();
    rayLocal.getDirection().normalize();
    IntersectionInfo localInfo = m_primitive.getIntersectionInfo( rayLocal, tMin/scale, tMax/scale );
    if ( localInfo == null )
    {
      return null;
    }

    Point point = m_transform.localToWorld( localInfo.point() );
    Vector normal = m_transform.localToWorldNormal( localInfo.normal() );
    ShapeIntersectionInfo intersectionInfo = new ShapeIntersectionInfo( point, normal, localInfo.t()*scale, localInfo.fDualSided() );
    return new IntersectionInfo( this, intersectionInfo );
  }
  
  public Material getMaterial()
  {
    return m_primitive.getMaterial(); 
  }
  
  public Box getBoundingBox()
  {
    return m_boundingBox; 
  }
}
