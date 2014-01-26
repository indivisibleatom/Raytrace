interface Light extends Primitive
{
  //TODO msati3 : Remove this hack later. Do we need getShape in Primitive?
  public Shape getShape();
}

class PointLight implements Light
{
  private Point m_position;

  public Shape getShape() { return null; }
}

