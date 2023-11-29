# MeasuringSearchRelevance

This app helps with measuring the relevancy of search results

## Overview

It turns out that measuring the effectiveness of search results is a subjective challenge. 
There's a variety of mechanisms you can use. 
This app provides the metrics for you to evaluate on based on common search relevancy metrics.

Normalized Discounted Cumulative Gain (NDGC) is a statistical measurement that's based on the idea that returned search results may be partially relevant - on a gradient of some scale, and that the higher ranking search be the most relevant results. 
It's the same pattern that's used in many (good) news article layouts: the most pertinent information is provided first, lessor details follow.

- [Demystifying NDCG](https://towardsdatascience.com/demystifying-ndcg-bee3be58cfe0#:~:text=NDCG%20(normalized%20discounted%20cumulative%20gain,are%20lower%20in%20the%20ranking.))

### Section header

To get this information

1. collect a set of search terms, and their associated results
2. present that to a human being to evaluate how relevant they think the search results are
3. collect the data from ideally more than one person, and from more than one set of search results
4. combine all the results to form a statistical view of "how effective the search" is over a given period of time.


