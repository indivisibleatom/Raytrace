//TODO msati3: Switch to acceleration structure at a later time?
class PrimitiveManager
{
  private ArrayList<LightedPrimitive> m_primitives;
  
  PrimitiveManager()
  {
    m_primitives = new ArrayList<LightedPrimitive>();
  }
  
  public void addPrimitive( LightedPrimitive primitive )
  {
    m_primitives.add(primitive);
  }
  
  public boolean intersects( Ray ray )
  {
    for (int i = 0; i < m_primitives.size(); i++)
    {
      if ( m_primitives.get(i).intersects( ray ) == true )
      {
        return true;
      }
    }
    return false;
  }
  
  public IntersectionInfo getIntersectionInfo( Ray ray )
  {
    float minT = Float.MAX_VALUE;   
    IntersectionInfo minIntersectionInfo = null;
    for (int i = 0; i < m_primitives.size(); i++)
    {
      if ( m_primitives.get(i).intersects( ray ) == true )
      {
        IntersectionInfo info = m_primitives.get(i).getIntersectionInfo( ray );
        if ( info != null )
        {
          if ( info.t() < minT )
          {
            minIntersectionInfo = info;
            minT = info.t();
          }
        }
      }
    }
    return minIntersectionInfo;
  }
}
