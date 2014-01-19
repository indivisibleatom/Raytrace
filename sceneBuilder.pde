class SceneBuilder
{
  private string m_fileName;
  Scene m_scene;
  
  SceneBuilder( string fileName )
  {
    m_fileName = fileName;
  }
  
  private void setCameraFov(int angle)
  {
    m_scene.setCameraFov(angle);
  }
  
  private void setBackgroundColor(Color bgColor)
  {
    m_scene.setBackgroundColor(bgColor);
  }
  
  private void addPointLight(Point location, Color color)
  {
    m_scene.addPointLight(locatio, color);
  }
  
  private void raytrace()
  {
    m_scene.raytrace();
  }
  
  void buildScene()
  { 
    String str[] = loadStrings(m_fileName);
    if (str == null) 
    {
      println("Error! Failed to read the file.");
    }

    for (int i=0; i<str.length; i++) 
    {     
      String[] token = splitTokens(str[i], " "); // Get a line and parse tokens.
      if (token.length == 0) continue; // Skip blank line.
      
      if (token[0].equals("fov"))
      {
        int angle = Integer.parseInt(token[1]);
        setCameraFov(angle);
      }
      else if (token[0].equals("background")) 
      {
        //TODO msati3: Create functions for parsing such tuples?
        Color bgColor = new Color( Float.parseFloat(token[1]), Float.parseFloat(token[2]), Float.parseFloat(token[3]));
        setBackgroundColor(bgColor);
      }
      else if (token[0].equals("point_light")) 
      {
        Point location = new Point( Float.parseFloat(token[1]), Float.parseFloat(token[2]), Float.parseFloat(token[3]) );
        Color color = new Color( Float.parseFloat(token[4]), Float.parseFloat(token[5]), Float.parseFloat(token[6]) );
        addPointLight(location, color);
      }
      else if (token[0].equals("diffuse"))
      {
        // TODO
      }    
      else if (token[0].equals("sphere")) 
      {
        float radius = Float.parseFloat(token[1]);
        Point center = new Point( Float.parseFloat(token[2], Float.parseFloat(token[3]), Float.parseFloat(token[4]));
        addSphere(radius, center);
      }
      else if (token[0].equals("begin")) 
      {
        Point vertex = new Point( Float.parseFloat(token[1], Float.parseFloat(token[2]), Float.parseFloat(token[3]));
        // TODO
      }
      else if (token[0].equals("vertex")) {
        // TODO
      }
      else if (token[0].equals("end")) 
      {
        // TODO
      }
      else if (token[0].equals("push"))
      {
        //TODO
      }
      else if (tokens[0].equals("pop"))
      {
        //TODO
      }
      else if (tolens[0].equals("translate"))
      {
        Vector translate = new Vector( Float.parseFloat(token[1], Float.parseFloat(token[2]), Float.parseFloat(token[3]));
      }
      else if (tokens[0].equals("scale"))
      {
        Vector scaleFactor = new Vector( Float.parseFloat(token[1], Float.parseFloat(token[2]), Float.parseFloat(token[3]));
      }
      else if (tokens[0].equals("rotate"))
      {
        //TODO
      }  
      else if (token[0].equals("write")) 
      {
        // save the current image to a .png file
        raytrace();
        save(token[1]);
      }
      
      //Debug parser debug code
      else if (token[0].equals("color")) 
      {
        Color color = new Color( Float.parseFloat(token[1]), Float.parseFloat(token[2]), Float.parseFloat(token[3]) );
        fill(color.R(), color.G(), color.B());
      }
      else if (token[0].equals("rect")) 
      {
        float x0 = float(token[1]);
        float y0 = float(token[2]);
        float x1 = float(token[3]);
        float y1 = float(token[4]);
        rect(x0, screen_height-y1, x1-x0, y1-y0);
      }
    }
  }
}
