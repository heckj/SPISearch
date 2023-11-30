# SPISearch Use Cases

The planned use cases for the SPISearch app in helping investigate and report on search relevancy for the Swift Package Index. 

## Overview

- Collecting, or importing, searches into a search collection
- Providing a means to easily and quickly add subjective review of the results
- Showing a rank-agnostic review of a search collection
- Showing a rank-relevant review of a search collection, when ranking is sufficiently complete
- Collaborating on combining ranking information from multiple people.

### Building a Search Collection

The core of this app is meant to ease collecting the relevancy feedback for a collection of searches. 
In order to do that, it needs a collection to work on and share - so there is functionality to create a new "search collection":

- import an existing search collection
- create a new search collection
- edit a search collection (adding search terms and results)

### Ranking Search Results

With an existing collection in hand, the app should focus on getting relevancy reviews for the results within the collection.
Every individual using the app gets a unique identifier that is used to track their rankings. 
For each search collection, the app tracks how much of that collection has been ranked by the person using the app.
There's a "quick rank" app function that makes it very easy to stay focused on providing rankings for the current search collection, adding rankings for anything yet to be  done. 
When all rankings for the current user are complete, the "quick rank" drops  back into a summary view of the search collection.

When viewing a search collection, you see some basic metrics about it - how many searches, the dates for each search, and the amount of coverage for the relevancy rankings.

### Showing Search Collection Summary

Core Search Collection:
- number of searches
- date range of the searches (searches collected between date X and date Y)

Ranking Information:
- number of people providing rankings (list of them?)
- percent coverage per person
- overall coverage percentage
- NDCG ranking (value 0...1) for each search that has rankings
- NDCG ranking for the overall collection (distribution? median?) where rankings have been applied

### Browsing Ranked Collections

Show a list of the searches:
- order by date || order by % coverage || order by NDCG ranking
- display search terms and results
- color code/tone the results by relevancy
- show NDCG ranking for the search
- show the median NDCG ranking value for the collection
- (? maybe show where in the NDCG distribution this search's ranking resides)

### Collaborating on Ranking Information

Importing and merging ranking documents from others
