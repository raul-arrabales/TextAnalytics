
# Kaggle's Bag of Words Meets Bags of Popcorn
# Code adapted from John Koo
# See: https://drive.google.com/file/d/0B_sqyEYBKc1wVm4xN0NvQlJlNWc/view 


# My folder/prject with all the Kaggle Porcorn data
# See https://www.kaggle.com/c/word2vec-nlp-tutorial 
# setwd('R/popcorn')

# Loading data...


# Kaggle data sets: 

train.labeled <- read.delim('labeledTrainData.tsv',
                             header = T, 
                             quote = '', 
                             stringsAsFactors = F)

train.unlabeled <- read.delim('unlabeledTrainData.tsv',
                              header = T, 
                              quote = '', 
                              stringsAsFactors = F)

test <- read.delim('testData.tsv',
                   header = T, 
                   quote = '', 
                   stringsAsFactors = F)

# AFINN data set 
# See http://www2.imm.dtu.dk/pubdb/views/publication_details.php?id=6010
# read in the AFINN list

afinn <- read.delim('AFINN-111.txt',
                    header = F, 
                    quote = '', 
                    stringsAsFactors = F)

# Clean up and prepare for matching
names(afinn) <- c('word', 'score')
afinn$word.clean <- gsub('-', ' ',afinn$word)
afinn$word.clean <- gsub("[[:punct:]]", '', afinn$word.clean)

# Combining data

all.data <- rbind(train.labeled[,-2], train.unlabeled, test)

all.data$sentiment <- c(train.labeled$sentiment,
                        rep(NA, nrow(train.unlabeled) + nrow(test)))


# Adding an index

train.labeled.ind <- 1:nrow(train.labeled)
train.ind <- 1:(nrow(train.labeled) + nrow(train.unlabeled))
test.ind <- (nrow(train.labeled) + nrow(train.unlabeled) + 1):nrow(all.data)

# cleaning text 

# remove HTML tags
all.data$review.clean <- gsub('<.*?>', ' ', all.data$review)

# remove grammar/punctuation
all.data$review.clean <- tolower(gsub('[[:punct:]]', '', all.data$review.clean))

# Calculate TF (term frequency) of AFINN words in movie reviews
require(stringr)
tf <- t(apply(t(all.data$review.clean), 2,
              function(x) str_count(x, afinn$word.clean)))

# sentiment rating for each row
all.data$afinn.rating <- as.vector(tf %*% afinn$score)

# See the overlap between the two classes
require(ggplot2)
ggplot(all.data[train.labeled.ind, ],
       aes(afinn.rating, fill = as.factor(sentiment))) +
  geom_density(alpha = .2)


# Training a naive bayes classifier
require(e1071)
nb.model <- naiveBayes(sentiment ~ afinn.rating,
                       data = all.data[train.labeled.ind, ])

# Testing the model
nb.pred <- predict(nb.model,
                   newdata = all.data[test.ind, ],
                   type = 'raw')

# format results for submission
results <- data.frame(id = all.data$id[test.ind],
                      sentiment = nb.pred[, 2])
results$id <- gsub('"', '', results$id)

write.table(results, file = 'afinn_rating.csv',
                    sep = ',', row.names = F, quote = F)

########################################################
# Up to this point we have a working classifier, but  
# maybe we want to investigate how to build a better
# feature vector representation for the documents and
# how to use more complex classifiers, such as a random
# forest...
########################################################
                
              
# Let's now use a random forest

# First, Bag of Scores (using AFINN instead of word2vec)
# scores range from -5 to 5
score.vectorizer <- function(sentence, words, word.scores)
{
  score.vector <- rep(0, length(table(word.scores)))
  k <- 0
  for (i in as.numeric(names(table(word.scores))))
  {
      k <- k + 1
      tempwords <- words[word.scores == i]
      score.vector[k] <- sum(str_count(sentence, tempwords))
  }
  return(score.vector)
}

score.data <- as.data.frame(
  t(apply(t(all.data$review.clean), 2,
          function(x) score.vectorizer(x,
                                       afinn$word.clean,
                                       afinn$score))))

# name columns
names(score.data) <- c('n5', 'n4', 'n3', 'n2', 'n1',
                        'zero',
                        'p1', 'p2', 'p3', 'p4', 'p5')


# Trainig a random forest classifier
require(randomForest)

bag.of.scores.forest <- randomForest(score.data[train.labeled.ind, ],
                                     as.factor(train.labeled$sentiment))

bag.of.scores.forest.pred <- predict(bag.of.scores.forest,
                                     newdata = score.data[test.ind, ],
                                     type = 'prob')

results <- data.frame(id = all.data$id[test.ind],
                      sentiment = bag.of.scores.forest.pred[, 2])

results$id <- gsub('"', '', results$id)

write.table(results,
            file = 'bag_of_scores.csv',
                    sep = ',', row.names = F, quote = F)


# Using TF-IDF Algorithm to train the random forest

tf <- as.data.frame(tf) 
idf <- log(length(train.ind)/colSums(sign(tf[train.ind, ])))
tf.idf <- as.data.frame(t(apply(tf, 1, function(x) x * idf)))

# Train the forest
tfidf.forest <- randomForest(tf.idf[train.labeled.ind, ],
                             as.factor(all.data$sentiment[train.labeled.ind]),
                             ntree = 100)

# Testing and getting results
tfidf.forest.pred <- predict(tfidf.forest,
                             newdata = tf.idf[test.ind, ],
                             type = 'prob')

results <- data.frame(id = all.data$id[test.ind],
                      sentiment = tfidf.forest.pred[, 2])
results$id <- gsub('"', '', results$id)

write.table(results,
            file = 'tfidf_afinn.csv',
            sep = ',', row.names = F, quote = F)

  
# Now building a TF matrix from the corpus using tm
require(tm)
                
# construct corpus (using only training data)
corpus <- Corpus(VectorSource(all.data$review.clean[train.ind]))

# tf matrix using all words (minus stop words)
# list of stop words can be found at
# http://jmlr.csail.mit.edu/papers/volume5/lewis04a/a11-smart-stop-list/english.stop
tf <- DocumentTermMatrix(corpus, control = list(stopwords = stopwords(’english’),
                                                removeNumbers = T))
                
# only include words that occur in at least .1% of reviews
tf <- removeSparseTerms(tf, .999)

# convert to dense matrix for easier analysis
tf <- as.matrix(tf)

# head(colnames(tf))

# Create a TF data frame
# sum up the columns to find the occurrences of each word in the corpus
word.freq <- colSums(tf)

# put in nicer format
word.freq <- data.frame(word = names(word.freq), freq = word.freq)
rownames(word.freq) <- NULL
  
# head(word.freq)
# head(word.freq[order(-word.freq$freq), ])
  
# Normalized difference  
word.freq <- function(document.vector, sparsity = .999)
{
  # construct corpus
  temp.corpus <- Corpus(VectorSource(document.vector))

  # construct tf matrix and remove sparse terms
  temp.tf <- DocumentTermMatrix(temp.corpus,
                                control = list(stopwords = stopwords(’english’),
                                               removeNumbers = T))
  temp.tf <- removeSparseTerms(temp.tf, sparsity)
  temp.tf <- as.matrix(temp.tf)

  # construct word frequency df
  freq.df <- colSums(temp.tf)
  freq.df <- data.frame(word = names(freq.df), freq = freq.df)
  rownames(freq.df) <- NULL
  return(freq.df)
}

word.freq.pos <- word.freq(all.data$review.clean[all.data$sentiment == 1])
word.freq.neg <- word.freq(all.data$review.clean[all.data$sentiment == 0])

# head(word.freq.pos)
  
# merge by word
freq.all <- merge(word.freq.neg, word.freq.pos, by = ’word’, all = T)

# clean up
freq.all$freq.x[is.na(freq.all$freq.x)] <- 0
freq.all$freq.y[is.na(freq.all$freq.y)] <- 0

# compute difference
freq.all$diff <- abs(freq.all$freq.x - freq.all$freq.y)

# head(freq.all[order(-freq.all$diff), ])
  
# smoothing term
alpha <- 2**7

# ndsi
freq.all$ndsi <- abs(freq.all$freq.x -
                     freq.all$freq.y)/(freq.all$freq.x +
                                       freq.all$freq.y + 2*alpha)

# head(freq.all[order(-freq.all$ndsi), ])
  
# number of words to consider in tf-idf matrix
num.features <- 2**10

# sort the frequency data
freq.all <- freq.all[order(-freq.all$ndsi), ]

# cast word to string
freq.all$word <- as.character(freq.all$word)

# build the tf matrix
tf <- t(apply(t(all.data$review.clean), 2,
              function(x) str_count(x, freq.all$word[1:num.features])))

# idf vector
idf <- log(length(train.ind)/colSums(sign(tf[train.ind, ])))
idf[is.infinite(idf)] <- 0

# tf-idf matrix
tf.idf <- as.data.frame(t(apply(tf, 1, function(x) x * idf)))
colnames(tf.idf) <- freq.all$word[1:num.features]

# train random forest classifier
ndsi.forest <- randomForest(tf.idf[train.labeled.ind, ],
                            as.factor(all.data$sentiment[train.labeled.ind]),
                            ntree = 100)

# predict and write output
ndsi.pred <- predict(ndsi.forest,
                     newdata = tf.idf[test.ind, ],
                     type = ’prob’)

results <- data.frame(id = all.data$id[test.ind],
                      sentiment = bag.of.scores.forest.pred[, 2])

results$id <- gsub('"', '', results$id)

write.table(results,
            file = 'ndsi_tfidf.csv',
            sep = ',', row.names = F, quote = F)

# Optimization
# tf <- tf[, colnames(tf) %in% freq.all$word]
# tf.idf <- DocumentTermMatrix(corpus, control = list(stopwords = stopwords(’english’),
#                                                     removeNumbers = T,
#                                                     weighting = function(x) weightTfIdf(x, normalize = F)))
                                                        
                                                        
