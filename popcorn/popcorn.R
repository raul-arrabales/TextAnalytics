
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
