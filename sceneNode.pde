interface SceneNode
{
  public void update();
}

class ShapeNode implements SceneNode
{
  private Shape m_shape;

  public void update()
  {
  }
}

class TransformationNode implements SceneNode
{
  private Transformation m_transform;
  
  public void update()
  {
  }
}
