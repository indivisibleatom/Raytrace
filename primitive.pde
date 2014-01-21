interface Primitive
{
}

class GeometricPrimitive implements Primitive
{
  private Shape m_shape;
}

//Stores a reference to the actual primitive and a reference to a transform to take
class InstancePrimitive implements Primitive
{
  private Primitive m_primitive;
  private Transform m_worldTransform;
}
