class GeneticAlgorithm
{
  int generation;
  float mutationRate;
  ArrayList<DNA> population;
  
  //should be called bestDNA...?
  float[] bestGenes;
  
  // used when selecting parents
  float fitnessSum;
  
  // used for checking when to stop the algorithm
  float bestFitness;
  
  GeneticAlgorithm(int populationSize, int dnaSize, float mutationRate_)
  {
    generation = 1;
    mutationRate = mutationRate_;
    
    // Storing the fittest set of genes
    bestGenes = new float[dnaSize];
    
    // Creating the population
    population = new ArrayList<DNA>();
    for(int i = 0; i < populationSize; i++)
    {
      population.add(new DNA(dnaSize, true));
    } //<>//
  }
  
  void newGeneration()
  {
    if(population.size() <= 0)
    {
      return;
    }
    
    calculateFitness();
    
    ArrayList<DNA> newPopulation = new ArrayList<DNA>();

    for(int i = 0; i < population.size(); i++)
    {
      DNA child;
      if(multiSelection)
      {
        child = multipleCrossover();
      }
      else
      {
        child = pairCrossover();
      }
       //<>//

      child.mutate(mutationRate);

      newPopulation.add(child);
    }

    population = newPopulation;

    generation++;
  }
  
  // performs crossover on two parents to produce a child
  DNA pairCrossover()
  {
    DNA parent1 = population.get(ChooseParent());
    DNA parent2 = population.get(ChooseParent());
    
    DNA child = parent1.crossover(parent2);
    return child;
  }
  
  // takes 5 parents and crosses them all to produce one offspring
  DNA multipleCrossover()
  {
    ArrayList<DNA> parents = (ArrayList<DNA>)population.clone();
    Collections.sort(parents, new DNAComparator());
    parents.subList(5, parents.size()).clear();
    DNA [] parentsArray = new DNA[5];
    parents.toArray(parentsArray);
      
    DNA child = new DNA(dnaSize, false);
    for(int i = 0; i < dnaSize; i++)
    {
      float random = random(1);
      if(random <= 0.2)
      {
        child.genes[i] = parentsArray[0].genes[i];
      }
      else if(random <= 0.4)
      {
        child.genes[i] = parentsArray[1].genes[i];
      }
      else if(random <= 0.6)
      {
        child.genes[i] = parentsArray[2].genes[i];
      }
      else if(random <= 0.8)
      {
        child.genes[i] = parentsArray[3].genes[i];
      }
      else if(random <= 1)
      {
        child.genes[i] = parentsArray[4].genes[i];
      }
      
    }
    
    return child;
  }
  
  void calculateFitness()
  {
    // The fitnesses of all the population combined
    fitnessSum = 0;

    DNA best = population.get(0);

    //int bestDNAIndex = 0;
    
    for(int i = 0; i < population.size(); i++)
    {
      
      fitnessSum += population.get(i).calculateFitness(i);

      if(population.get(i).fitness > best.fitness)
      {
        best = population.get(i);
        //bestDNAIndex = i;
      }
    }

    bestFitness = best.fitness;
    
    bestGenes = best.genes;
  }
  
  // SELECTION
  ///////////////////////////////////////////////////////////////////////////////////////////////
  
  // returns the index of the fittest DNA
  int ChooseFittestParent()
  {
    int fittestIndex = 0;
    for(int i = 1; i < population.size(); i++)
    {
      if(population.get(i).fitness > population.get(fittestIndex).fitness)
      {
        fittestIndex = i;
      }
    }
    return fittestIndex;
    
  }
  
  // "roullete wheel selection"
  // more likely to choose fitter cars.
  // returns the index of the parent in the population array
  int ChooseParent()
  {
    //return selectionFunction();
    float randomNumber = random(1) * fitnessSum;
    
    // This algorithm has the effect of being more likely to choose fitter parents.
    for(int i = 0; i < population.size(); i++)
    {
      if(randomNumber < population.get(i).fitness)
      {
        return i;
      }
      randomNumber -= population.get(i).fitness;
    }
    return (int)random(population.size());   
  }
  

}
