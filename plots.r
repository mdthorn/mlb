library(ggplot)
library(scales)

# plot avg. run differential per game

avg_margin <- ggplot(avg_margin, aes(x=team, y=avg_margin)) + geom_bar(stat="identity") +
  xlab("") + ylab("Avg. Run Differential Per Game") + coord_flip()

# plot relationship between total win % and one-run win %

ggplot(grades_by_month, aes(x=month, y=value, group=variable, color=variable)) + 
  geom_line() + geom_hline(aes(yintercept=avg), linetype="dashed", color="gray57") +
  xlab("") + ylab("% of Restaurants with 'A' Grade") + scale_y_continuous(labels=percent) +
  theme(legend.position="none") + ggtitle("NYC Restaurant Grades by Month of Year") +
  theme(plot.title=element_text(face="bold")) + facet_wrap(~ variable, ncol=1)
