class LightManager
{
  private ArrayList<Light> m_lights;
  private Color m_ambientLight;
  
  LightManager()
  {
    m_ambientLight = new Color(0.2,0.2,0.2);
    m_lights = new ArrayList<Light>();
  }
  
  public void setAmbient(Color ambient){ m_ambientLight = ambient; }
  public void addLight(Light light) { m_lights.add( light ); }
  public Color getAmbient() { return m_ambientLight; }
  public int getNumLights() { return m_lights.size(); }
  public Light getLight( int i ) { return m_lights.get( i ); }
}
