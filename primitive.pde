interface Primitive
{
  public boolean intersects( Ray ray, float tMin, float tMax ); 
  public IntersectionInfo getIntersectionInfo( Ray ray, float tMin, float tMax );
}

interface LightedPrimitive extends Primitive
{
  public Color getDiffuseCoeffs();
  public Color getAmbientCoeffs();
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
   
  public boolean intersects( Ray ray, float tMin, float tMax )
  {
    return m_shape.intersects( ray, tMin, tMax );
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
    return new IntersectionInfo( this, getDiffuseCoeffs(), getAmbientCoeffs(), shapeInfo );
  }
  
  public Color getDiffuseCoeffs() { return m_material.getDiffuse(); }
  public Color getAmbientCoeffs() { return m_material.getAmbient(); }
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
  
  public boolean intersects( Ray ray, float tMin, float tMax ) 
  {
    Ray rayLocal = m_transform.worldToLocalUnnormalized( ray );
    float scale = 1/rayLocal.getDirection().getMagnitude();
    rayLocal.getDirection().normalize();
    return m_primitive.intersects( rayLocal, tMin/scale, tMax/scale );
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
    return new IntersectionInfo( this, getDiffuseCoeffs(), getAmbientCoeffs(), intersectionInfo );
  }
  
  public Color getDiffuseCoeffs()
  {
    return m_primitive.getDiffuseCoeffs(); 
  }
  
  public Color getAmbientCoeffs() 
  {
    return m_primitive.getAmbientCoeffs(); 
  }
  
  public Box getBoundingBox()
  {
    return m_boundingBox; 
  }
}
