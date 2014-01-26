//TODO msati3: Switch to acceleration structure at a later time?
class PrimitiveManager
{
  private ArrayList<Primitive> m_primitives;
  
  PrimitiveManager()
  {
    m_primitives = new ArrayList<Primitive>();
  }
  
  public void addPrimitive( Primitive primitive )
  {
    m_primitives.add(primitive);
  }
  
  public boolean intersects( Ray ray )
  {
    for (int i = 0; i < m_primitives.size(); i++)
    {
      if ( m_primitives.get(i).getShape().intersects( ray ) == true )
      {
        return true;
      }
    }
    return false;
  }
}
