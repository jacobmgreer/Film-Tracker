library(jsonlite)
library(dplyr)

dummyDF <- data.frame(sectionId = c(rep(1,9),rep(2,3)),
                      questionId = c(rep(1,3),rep(2,6),rep(3,3)),
                      subquestionId = c(rep(NA,3),rep("2a",3),rep("2b",3),rep(NA,3)),
                      deptManagerQId = c(rep("m1",3),rep("m2",3),rep("m3",3),rep("m4",3)),
                      deptEmployeeQId = c(rep("e1",3),rep("e3",3),rep("e4",3),rep("e7",3)),
                      optionId = rep(c(1,2,3),4),
                      text = rep(c("yes","neutral","no"),4))

json <- jsonlite::toJSON(dummyDF)

rm(dummyDF)

# prettify(json)