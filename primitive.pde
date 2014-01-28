interface Primitive
{
  public boolean intersects( Ray ray );
  
  //TODO msati3: Are these to be placed here?
  public float[] getDiffuseCoeffs();
  public float[] getAmbientCoeffs();
}

class GeometricPrimitive implements Primitive
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
  
  public float[] getDiffuseCoeffs() { return m_material.getDiffuse(); }
  public float[] getAmbientCoeffs() { return m_material.getAmbient(); }
}

//Stores a reference to the actual primitive and a reference to a transform to take
class InstancePrimitive implements Primitive
{
  private Primitive m_primitive;
  private Transformation m_transform;
  
  public boolean intersects( Ray ray ) { return m_primitive.intersects( ray ); }
  public float[] getDiffuseCoeffs() { return m_primitive.getDiffuseCoeffs(); }
  public float[] getAmbientCoeffs() { return m_primitive.getAmbientCoeffs(); }
}
