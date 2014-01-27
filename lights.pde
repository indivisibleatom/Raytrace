interface Light extends Primitive
{
}

class PointLight implements Light
{
  private Point m_position;

  public boolean intersects( Ray ray )
  {
    return false;
  }
}

