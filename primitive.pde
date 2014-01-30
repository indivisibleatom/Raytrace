interface Primitive
{
  public boolean intersects( Ray ray ); 
  public IntersectionInfo getIntersectionInfo( Ray ray );
}

interface LightedPrimitive extends Primitive
{
  public Color getDiffuseCoeffs();
  public Color getAmbientCoeffs();
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
    
  public boolean intersects( Ray ray )
  {
    return m_shape.intersects( ray );
  }

  public IntersectionInfo getIntersectionInfo( Ray ray )
  {
    ShapeIntersectionInfo shapeInfo =  m_shape.getIntersectionInfo( ray );
    if ( shapeInfo == null )
    {
      if (DEBUG && DEBUG_MODE >= LOW)
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
  
  public boolean intersects( Ray ray ) { return m_primitive.intersects( ray ); }
  public IntersectionInfo getIntersectionInfo( Ray ray ) { return m_primitive.getIntersectionInfo( ray ); }
  public Color getDiffuseCoeffs() { return m_primitive.getDiffuseCoeffs(); }
  public Color getAmbientCoeffs() { return m_primitive.getAmbientCoeffs(); }
}
