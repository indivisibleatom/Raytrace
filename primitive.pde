interface Primitive
{
  public Shape getShape();
}

class GeometricPrimitive implements Primitive
{
  private Shape m_shape;
  
  GeometricPrimitive( Shape shape )
  {
    m_shape = shape;
  }
  
  public Shape getShape() { return m_shape; }
}

//Stores a reference to the actual primitive and a reference to a transform to take
class InstancePrimitive implements Primitive
{
  private Primitive m_primitive;
  //private Transform m_worldTransform;
  
  public Shape getShape() { return m_primitive.getShape(); }
}
