
class DNA 
{
  float[] genes;
  
  float fitness;
  
  DNA(int size, boolean shouldInitGenes)
  {
    genes = new float[size];
    
    fitness = 0;
    
    // generating strand of DNA
    if(shouldInitGenes)
    {
      // 0 - 7 : chassis angles
      // 8 - 15 : chassis distances
      // 16 : front wheel size
      // 17 : back wheel size
      for(int i = 0; i < genes.length; i++)
      {        
        if(i <= 7)
        {
          genes[i] = TWO_PI / 8 * i + random(TWO_PI / 8) - TWO_PI / 16;
        }
        else if(i <= 15)
        {
          genes[i] = random(40) + 50;
        }
        else if(i <= 17)
        {
          genes[i] = random(70) + 30;
        }
      }
    }
  }
  
  public DNA crossover(DNA otherParent)
  {
    DNA child = new DNA(genes.length, false);

    for(int i = 0; i < genes.length; i++)
    {
      child.genes[i] = random(1) < 0.5 ? genes[i] : otherParent.genes[i];
    }

    return child;
  }
  
  public void mutate(float mutationRate)
  {
    for(int i = 0; i < genes.length; i++)
    {
      if(random(1) < mutationRate)
      {
        // call the desired mutation function.
        genes[i] = mutationFunction(i, genes[i]);
      }
    }
  }
  
  // This is redundant in this implementation but if the fitness function was being passed in to the class then it could handle a range of fitness functions
  float calculateFitness(int index)
  {
    // storing the fitness in a variable before returning it, for later use
    fitness = fitnessFunction(index);
    return fitness;
  }
}

// comparator class used for sorting a list of DNA objects by fitness
class DNAComparator implements Comparator<DNA> {
 int compare(DNA a, DNA b) {
   return (int)b.fitness - (int)a.fitness;
 }
}
