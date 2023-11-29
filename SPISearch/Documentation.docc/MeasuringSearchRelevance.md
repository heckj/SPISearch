# MeasuringSearchRelevance

This app helps with measuring the relevancy of search results

## Overview

It turns out that measuring the effectiveness of search results is a subjective challenge. 
There's a variety of mechanisms you can use. 
This app provides the metrics for you to evaluate on based on common search relevancy metrics.

The keys of search metrics start with three concepts: Relevance, Ranking, and Recall.
Achieving good relevance is a balance between precision (a boolean indicator whether a result is useful or not) and recall (the percentage of all possible entries that ARE relevant).
Wikipedia has a good [summary precision and recall](https://en.wikipedia.org/wiki/Precision_and_recall#Precision).

These base concepts can be made more nuanced by allowing for a non-binary answer to "is this relevant", which allows for the idea  that some answers are more relevant than others, on a sliding scale. Add to the concept of "the top answers should be better", and you get measures of [cumulative gain (CG), discounted cumulative gain (DCG), and normalized discounted cumulative gain (NDCG)](https://en.wikipedia.org/wiki/Discounted_cumulative_gain).

Normalized Discounted Cumulative Gain (NDCG) is a statistical measurement that's based on the idea that returned search results may be partially relevant - on a gradient of some scale, and that the higher ranking search be the most relevant results. 
It's the same pattern that's used in many (good) news article layouts: the most pertinent information is provided first, lessor details follow.
Some of the more accurate measures of relevance are extraordinarily awkward to measure, simply because it assumes that the measuring process has perfect knowledge of the entire index and what might be available.
In the case of an ever-changing index, even of the relatively small size of the Swift Package Index, that's not terribly practical.
So instead we focus on measuring what we do see from the top 'N' results provided.

For more information on NDCG, see [Demystifying NDCG](https://towardsdatascience.com/demystifying-ndcg-bee3be58cfe0).

### Key App Use Cases

To get the information to support building up an NDCG measure for the search results from Swift Package Index, we need to enable the following:

1. collect a set of search terms, and their associated results
2. present that to a human being to evaluate how relevant they think the search results are
3. collect the data from ideally more than one person, and from more than one set of search results
4. combine all the results to form a statistical view of "how effective the search" is over a given period of time.


