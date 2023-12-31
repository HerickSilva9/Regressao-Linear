# Professor: Cassius Henrique

# Aula 22 - Exemplo 2
# Modelo de regressao linear simples

rm(list=ls(all=TRUE))

require(tidyverse)
require(plotly)
require(lmtest)
require(ggfortify)
require(broom)
require(ggExtra)
require(car)



# Dados
dt <- read.csv("~/EstR/est057/dados/SalarioExperiencia.csv",
               header = TRUE, sep = ";", dec = ".")

glimpse(dt)

# Retirando linhas da base de dados (apenas para curiosidade)
# dt <- dt[-18,]


# Estatisticas descritivas
summary(dt$salario)
summary(dt$experiencia)
cor(dt$experiencia, dt$salario)



resposta <- ggplot(dt, aes(x = experiencia))+
  geom_histogram(aes(y = after_stat(count / sum(count))),
                 bins = 7, fill="blue")+
  scale_y_continuous(labels = scales::percent)+
  labs(y="FR",
       x="experiencia (em R$1000,00)",
       title="Histograma")+
  theme(text = element_text(size = 12))
ggplotly(resposta)

disp <- ggplot(data = dt, aes(x = experiencia, y = salario)) +
  geom_point(color='blue') +
  ggtitle("Grafico de dispersao") +
  geom_smooth(method = "lm", se = TRUE)
ggplotly(disp)

disp2 <- ggplot(data = dt, aes(x = experiencia, y = salario)) +
  geom_point(color='blue') +
  ggtitle("Grafico de dispersao e boxplots marginais") +
  geom_smooth(method = "lm", se = TRUE)
ggplotly(disp2)

ggMarginal(disp,
           type = "boxplot",
           fill = "lightblue")


# Teste de correlacao
cor.test(dt$salario, dt$experiencia)


# Regressao linear
# y ~ x (y = resposta, x = explicativa)
modelo <- lm(salario ~ experiencia, data = dt)
summary(modelo)
confint(modelo)

# Graficos para analise do modelo:
# Aqui sera feita a analise da suposicao de independencia, de
# normalidade e de homocedasticidade. Tambem e possivel avaliar os
# pontos mais influentes
autoplot(modelo)


# Outra forma
plot(residuals(modelo))
plot(modelo,1)
plot(modelo,2)
plot(modelo,3)
plot(modelo,4)
plot(modelo,5)


res <- residuals(modelo) %>%
  as.data.frame()
names(res) <- "residuos"
res$x <- as.numeric(rownames(res))
ggres <- res %>%
  ggplot(aes(x = x, y = residuos)) +
  geom_point(color='blue', size = 3) +
  ggtitle("Residuos do modelo") +
  geom_hline(aes(yintercept = 0, colour = "red"), size=1) +
  guides(color = FALSE, size = FALSE)

ggMarginal(ggres,
           type = "boxplot",
           fill = "lightblue",
           margins = "y")

ggMarginal(ggres,
           type = "histogram",
           bins = ceiling(sqrt(nrow(res)))+2,
           fill = "lightblue",
           margins = "y")


model.diag.metrics <- augment(modelo)
head(model.diag.metrics)
ggplot(model.diag.metrics, aes(experiencia, salario)) +
  geom_point() +
  stat_smooth(method = lm, se = FALSE) +
  geom_segment(aes(xend = experiencia, yend = .fitted), color = "red", size = 0.3) +
  ggtitle("Residuos do modelo")


# ANOVA
summary(aov(modelo))

# Normalidade
# H0: residuos normais
# H1: residuos nao normais
shapiro.test( residuals(modelo) )


# Realizar o teste de Breusch-Pagan
# H0: residuos homocscedasticos
# H1: residuos heteroscedasticos
bptest(modelo)

# Teste de Durbin-Watson
# H0: autocorrelacao de residuos igual a zero
# H1: autocorrelacao de residuos maior zero
dwtest(modelo)


# gvlma::gvlma(modelo)




