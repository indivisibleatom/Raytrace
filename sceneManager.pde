class SceneManager
{
  private SceneGraph m_sceneGraph;
  private PrimitiveManager m_primitiveManager;
  
  SceneManager()
  {
    //TODO msati3: See if we need to implement a scenegraph
    m_primitiveManager = new PrimitiveManager();
  }
  
  void addPrimitive(Primitive p)
  {
    m_primitiveManager.addPrimitive(p);
  }
  
  boolean intersects( Ray ray )
  {
    return m_primitiveManager.intersects( ray );
  }
}
