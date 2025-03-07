# Pacotes
library('ggplot2')
library('dplyr')
library('nycflights13')

# Based on the Flights library, let's create a new dataset called pop_data,
# referring to the flights of the airlines UA (United Airlines) and DL (Delta Airlines).
# The dataset will have only two columns (company name and arrival flight delay).
pop_data <- na.omit(flights) %>% 
  filter(carrier %in% c('UA', 'DL'), arr_delay >= 0) %>% 
  select(carrier, arr_delay) %>% 
  group_by(carrier) %>% 
  sample_n(17000) %>% 
  ungroup()

# Creation of two samples with 1000 observations each from the pop_data dataset.
# Let's establish sample 1 with data from the company Delta Airlines (DL)
# Let's establish sample 2 with data from the company United Airlines (UA)
# And at the end join both samples in a single dataset
amostra1 <- na.omit(pop_data) %>% 
  select(carrier, arr_delay) %>% 
  filter(carrier == 'DL') %>% 
  mutate(sample_id = '1') %>% 
  sample_n(1000)

amostra2 <- na.omit(pop_data) %>% 
  select(carrier, arr_delay) %>% 
  filter(carrier == 'UA') %>% 
  mutate(sample_id = '2') %>% 
  sample_n(1000)

samples <- rbind(amostra1, amostra2)

# In this step, we will calculate the confidence interval (95%) for samples 1 and 2.
# Standard error
erro_padrao_amostra1 <- sd(amostra1$arr_delay) / sqrt(nrow(amostra1))
erro_padrao_amostra2 <- sd(amostra2$arr_delay) / sqrt(nrow(amostra2))

# This formula is used to calculate the standard deviation of a sample mean distribution
# (of a large number of samples from a population). In short, it is applicable when
# if you are looking for the standard deviation of averages calculated from a sample of
# size n, taken from a population.

# Lower and upper limits
# 1.96 is the z score value for 95% confidence
lower1 <- mean(amostra1$arr_delay) - 1.96 * erro_padrao_amostra1  
upper1 <- mean(amostra1$arr_delay) + 1.96 * erro_padrao_amostra1
lower2 <- mean(amostra2$arr_delay) - 1.96 * erro_padrao_amostra2
upper2 <- mean(amostra2$arr_delay) + 1.96 * erro_padrao_amostra2

# confidence interval
ic_1 <- c(lower1, upper1)
mean(amostra1$arr_delay)
ic_2 <- c(lower2, upper2)
mean(amostra2$arr_delay)

# Sample 1 has an average flight delay of DE 39,299 and a confidence interval
# of approximately (34.66 to 43.93), indicating that the mean is fully in.

# Sample 2 has an average flight delay DE 34.33 and a confidence interval
# from about (31.34 to 37.33), indicating that the mean is fully in.

# Creating a graph to visualize the previously created confidence intervals
toPlot <- summarise(group_by(samples, sample_id), mean = mean(arr_delay))
toPlot <- mutate(toPlot, lower = ifelse(toPlot$sample_id == 1, ic_1[1], ic_2[1]))
toPlot <- mutate(toPlot, upper = ifelse(toPlot$sample_id == 1, ic_1[2], ic_2[2]))

ggplot(toPlot, aes(x = sample_id, y = mean, colour = sample_id)) + 
  geom_point() + 
  geom_errorbar(aes(ymin = lower, ymax = upper), width = .1)

# Based on the data developed so far, it is possible to say that most likely,
# the samples came from the same population, due to the fact that most of the data resides
# in the same confidence interval in both samples.

# Now let's check if Delta Airlines (DL) flights are delayed more than Delta flights
# United Airlines (EU). Based on this question, we will do the hypothesis test.

# Null Hypothesis (H0) = There is no significant difference between DL and UA delays
# Difference of average delays = 0

# Alternative Hypothesis (HA) = DL flights are more delayed than UA flights
# Difference of delay means > 0

# Create the samples
dl <- sample_n(filter(pop_data, carrier == "DL", arr_delay > 0), 1000)
ua <- sample_n(filter(pop_data, carrier == "UA", arr_delay > 0), 1000)

# Calculate standard error and mean
se <- sd(dl$arr_delay) / sqrt(nrow(dl))
mean(dl$arr_delay)

# Lower and upper limits
lower <- mean(dl$arr_delay) - 1.96 * se
upper <- mean(dl$arr_delay) + 1.96 * se
ic_dl <- c(lower, upper)
ic_dl

# Repeat the process for the other company
se <- sd(ua$arr_delay) / sqrt(nrow(ua))
mean(ua$arr_delay)

lower <- mean(ua$arr_delay) - 1.96 * se
upper <- mean(ua$arr_delay) + 1.96 * se
ic_ua <- c(lower, upper)
ic_ua

# Students t-test
t.test(dl$arr_delay, ua$arr_delay, alternative = "greater")

# The p-value is a quantification of the probability of making a mistake in rejecting H0,
# resulting from the adopted statistical distribution. If the p-value is less than the
# significance level, it is concluded that it is correct to reject the null hypothesis.
# In short, this is the probability that the test statistic assumes a
# extreme value relative to the observed value when H0 is true.

# As a result, we fail to reject the null hypothesis because p-value is greater than
# the significance level (0.05). This means that there is a high probability
# that there is no significant difference between the delays. Based on our data,
# there is no statistical evidence that DL delays more than UA.
