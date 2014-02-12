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
    return new IntersectionInfo( this, shapeInfo );
  }
  
  public Color getDiffuseCoeffs() { return m_material.getDiffuse(); }
  public Color getAmbientCoeffs() { return m_material.getAmbient(); }
}

//Stores a reference to the actual primitive and a reference to a transform to take
class InstancePrimitive implements LightedPrimitive
{
  private LightedPrimitive m_primitive;
  private Transformation m_transform;
  
  public boolean intersects( Ray ray, float tMin, float tMax ) { return m_primitive.intersects( ray, tMin, tMax ); }
  public IntersectionInfo getIntersectionInfo( Ray ray, float tMin, float tMax ) { return m_primitive.getIntersectionInfo( ray, tMin, tMax ); }
  public Color getDiffuseCoeffs() { return m_primitive.getDiffuseCoeffs(); }
  public Color getAmbientCoeffs() { return m_primitive.getAmbientCoeffs(); }
  public Box getBoundingBox() { return m_primitive.getBoundingBox(); }
}
