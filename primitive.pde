interface Primitive
{
  public boolean intersects( Ray ray );

}

class GeometricPrimitive implements Primitive
{
  private Shape m_shape;
  
  GeometricPrimitive( Shape shape )
  {
    m_shape = shape;
  }
  
  public boolean intersects( Ray ray )
  {
    return m_shape.intersects( ray );
  }
}

//Stores a reference to the actual primitive and a reference to a transform to take
class InstancePrimitive implements Primitive
{
  private Primitive m_primitive;
  private Transformation m_transform;
  
  public boolean intersects( Ray ray ) { return m_primitive.intersects( ray ); }
}
