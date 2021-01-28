

/*
*PEOPLE ORIENTED

corr $peoplelist

* Principal component analysis (PCA)
pca $peoplelist

*Scree plot of the eigenvalues
screeplot
screeplot, yline(1)

* Principal component analysis
pca $peoplelist, mineigen(1) 
pca $peoplelist, covariance
pca $peoplelist, comp(6) 
pca $peoplelist, comp(6) blanks(.20) 

rotate, promax
rotate, promax blanks(.20)
rotate, clear

* KMO measure of sampling adequacy
estat kmo

*Scatter plots of the loadings and score variables
loadingplot
scoreplot

*paran $peoplelist, iterations(5000) graph

* Average interitem covariance
alpha $peoplelist, std item detail asis casewise

*SOLUTIONS ORIENTED

corr $solutionlist

* Principal component analysis (PCA)
pca $solutionlist

*Scree plot of the eigenvalues
screeplot
screeplot, yline(1)

* Principal component analysis
pca $solutionlist, mineigen(1) 
pca $solutionlist, covariance
pca $solutionlist, comp(5) 
pca $solutionlist, comp(5) blanks(.20) 

rotate, promax
rotate, promax blanks(.20)
rotate, clear

* KMO measure of sampling adequacy
estat kmo

*Scatter plots of the loadings and score variables
loadingplot
scoreplot

*paran $solutionlist, iterations(5000) graph

* Average interitem covariance
alpha $solutionlist, std item detail asis casewise

*INNOVATION ORIENTED

corr $innovationlist

* Principal component analysis (PCA)
pca $innovationlist

*Scree plot of the eigenvalues
screeplot
screeplot, yline(1)

* Principal component analysis
pca $innovationlist, mineigen(1) 
pca $innovationlist, covariance
pca $innovationlist, comp(3) 
pca $innovationlist, comp(3) blanks(.20) 

rotate, promax
rotate, promax blanks(.20)
rotate, clear

* KMO measure of sampling adequacy
estat kmo

*Scatter plots of the loadings and score variables
loadingplot
scoreplot

paran $innovationlist, iterations(5000) graph

* Average interitem covariance
alpha $innovationlist, std item detail asis casewise

*GROWTH ORIENTED

corr $growthlist

* Principal component analysis (PCA)
pca $growthlist

*Scree plot of the eigenvalues
screeplot
screeplot, yline(1)

* Principal component analysis
pca $growthlist, mineigen(1) 
pca $growthlist, covariance
pca $growthlist, comp(6) 
pca $growthlist, comp(6) blanks(.20) 

rotate, promax
rotate, promax blanks(.20)
rotate, clear

* KMO measure of sampling adequacy
estat kmo

*Scatter plots of the loadings and score variables
loadingplot
scoreplot

paran $growthlist, iterations(5000) graph

* Average interitem covariance
alpha $growthlist, std item detail asis casewise



***********OLD SCRIPT*****************

/*RELIABILITY CRONBACH ALPHA TEST

*PEOPLE SCORE USING COMPOSITE INDICATORS
cap noi alpha score1 score2 score3 score4 score5 score6 score7 score8 ///
score9 score10 score11 score12 score48 score49 score50 score51, std item detail asis casewise

*removing 49
cap noi alpha score1 score2 score3 score4 score5 score6 score7 score8 ///
score9 score10 score11 score12 score48 score50 score51, std item detail asis casewise

*removing 9
cap noi alpha score1 score2 score3 score4 score5 score6 score7 score8 ///
score10 score11 score12 score48 score50 score51, std item detail asis casewise

*removing 10
cap noi alpha score1 score2 score3 score4 score5 score6 score7 score8 ///
score11 score12 score48 score50 score51, std item detail asis casewise

*removing 7
cap noi alpha score1 score2 score3 score4 score5 score6 score8 ///
score11 score12 score48 score50 score51, std item detail asis casewise

*removing 8
cap noi alpha score1 score2 score3 score4 score5 score6 ///
score11 score12 score48 score50 score51, std item detail asis casewise
*resulting alpha:  0.8216, items: 11

*PEOPLE SCORE USING ALL QUESTIONS IN A
cap noi alpha score1a score2a score3a score4a score5a score6a score7a score8a ///
score9a score10a score11a score12a score48a score49a score50a score51a, std item detail asis

*removing 49a
cap noi alpha score1a score2a score3a score4a score5a score6a score7a score8a ///
score9a score10a score11a score12a score48a score50a score51a, std item detail asis

*removing 10a
cap noi alpha score1a score2a score3a score4a score5a score6a score7a score8a ///
score9a score11a score12a score48a score50a score51a, std item detail asis

*removing 7a
cap noi alpha score1a score2a score3a score4a score5a score6a score8a ///
score9a score11a score12a score48a score50a score51a, std item detail asis

*removing 8a
cap noi alpha score1a score2a score3a score4a score5a score6a ///
score9a score11a score12a score48a score50a score51a, std item detail asis

*removing 6a
cap noi alpha score1a score2a score3a score4a score5a ///
score9a score11a score12a score48a score50a score51a, std item detail asis

*removing 1a
cap noi alpha score2a score3a score4a score5a ///
score9a score11a score12a score48a score50a score51a, std item detail asis

*removing 2a
cap noi alpha score3a score4a score5a ///
score9a score11a score12a score48a score50a score51a, std item detail asis

*removing 9a
cap noi alpha score3a score4a score5a ///
score11a score12a score48a score50a score51a, std item detail asis
*resulting alpha: 0.8686, items: 8

*PEOPLE SCORE USING ALL QUESTIONS IN B
cap noi alpha score1b score2b score3b score4b score5b score6b score7b score8b ///
score9b score10b score11b score12b score48b score49b score50b score51b, std item detail asis

*removing 9b
cap noi alpha score1b score2b score3b score4b score5b score6b score7b score8b ///
score10b score11b score12b score48b score49b score50b score51b, std item detail asis

*removing 10b
cap noi alpha score1b score2b score3b score4b score5b score6b score7b score8b ///
score11b score12b score48b score49b score50b score51b, std item detail asis

*removing 49b
cap noi alpha score1b score2b score3b score4b score5b score6b score7b score8b ///
score11b score12b score48b score50b score51b, std item detail asis

*removing 3b
cap noi alpha score1b score2b score4b score5b score6b score7b score8b ///
score11b score12b score48b score50b score51b, std item detail asis

*removing 51b
cap noi alpha score1b score2b score4b score5b score6b score7b score8b ///
score11b score12b score48b score50b, std item detail asis
*resulting alpha: 0.8521, items: 11

*IN A: 49a, 10a, 7a, 8a, 6a, 1a, 2a, 9a
*IN B: 9b, 10b, 49b, 3b, 51b
*COMPOSITE: 49, 9, 10, 7, 8
*COMMON IN A AND B: 49, 9, 10

*SCORES WITH COMPOSITE AND MIXED VARIABLES
cap noi alpha score1 score2 score3 score4 score5 score6 score7b score8b ///
score11 score12 score48 score50 score51, std item detail asis
*resulting alpha: 0.9199, items: 13

*removing 1
cap noi alpha score2 score3 score4 score5 score6 score7b score8b ///
score11 score12 score48 score50 score51, std item detail asis casewise

*removing 3
cap noi alpha score2 score4 score5 score6 score7b score8b ///
score11 score12 score48 score50 score51, std item detail asis casewise

*removing 50
cap noi alpha score2 score4 score5 score6 score7b score8b ///
score11 score12 score48 score51, std item detail asis
*resulting alpha: 0.9537, items: 10

/*
POSSIBLE SCALE CONSTRUCTIONS FOR PEOPLE ORIENTED:
cap noi alpha score2 score4 score5 score6 score7b score8b ///
score11 score12 score48 score51, std item detail asis casewise
*resulting alpha: 0.9537, items: 10
*/

*SOLUTIONS SCORE USING COMPOSITE INDICATORS
cap noi alpha score13 score14 score15 score16 score17 score18 score19 score20 ///
score22 score23 score48 score50 score52 score53 score54, std item detail asis casewise

*removing 54
cap noi alpha score13 score14 score15 score16 score17 score18 score19 score20 ///
score22 score23 score48 score50 score52 score53, std item detail asis casewise

*removing 22
cap noi alpha score13 score14 score15 score16 score17 score18 score19 score20 ///
score23 score48 score50 score52 score53, std item detail asis casewise

*removing 18
cap noi alpha score13 score14 score15 score16 score17 score19 score20 ///
score23 score48 score50 score52 score53, std item detail asis casewise
*resulting alpha: 0.7860, items: 12

*SOLUTIONS SCORE USING ALL QUESTIONS IN A
cap noi alpha score13a score14a score15a score16a score17a score18a score19a score20a ///
score22a score23a score48a score50a score52a score53a score54a, std item detail asis 

*removing 54a
cap noi alpha score13a score14a score15a score16a score17a score18a score19a score20a ///
score22a score23a score48a score50a score52a score53a, std item detail asis

*removing 22a
cap noi alpha score13a score14a score15a score16a score17a score18a score19a score20a ///
score23a score48a score50a score52a score53a, std item detail asis

*removing 15a
cap noi alpha score13a score14a score16a score17a score18a score19a score20a ///
score23a score48a score50a score52a score53a, std item detail asis

*removing 17a
cap noi alpha score13a score14a score16a score18a score19a score20a ///
score23a score48a score50a score52a score53a, std item detail asis

*removing 18a
cap noi alpha score13a score14a score16a score19a score20a ///
score23a score48a score50a score52a score53a, std item detail asis

*removing 14a
cap noi alpha score13a score16a score19a score20a ///
score23a score48a score50a score52a score53a, std item detail asis

*removing 19a
cap noi alpha score13a score16a score20a ///
score23a score48a score50a score52a score53a, std item detail asis
*resulting alpha: 0.7640, items: 8

*SOLUTIONS SCORE USING ALL QUESTIONS IN B
cap noi alpha score13b score14b score15b score16b score17b score18b score19b score20b ///
score22b score23b score48b score50b score52b score53b score54b, std item detail asis

*removing 18b
cap noi alpha score13b score14b score15b score16b score17b score19b score20b ///
score22b score23b score48b score50b score52b score53b score54b, std item detail asis

*removing 19b
cap noi alpha score13b score14b score15b score16b score17b score20b ///
score22b score23b score48b score50b score52b score53b score54b, std item detail asis

*removing 52b
cap noi alpha score13b score14b score15b score16b score17b score20b ///
score22b score23b score48b score50b score53b score54b, std item detail asis

*removing 22b
cap noi alpha score13b score14b score15b score16b score17b score20b ///
score23b score48b score50b score53b score54b, std item detail asis

*removing 50b
cap noi alpha score13b score14b score15b score16b score17b score20b ///
score23b score48b score53b score54b, std item detail asis

*removing 54b
cap noi alpha score13b score14b score15b score16b score17b score20b ///
score23b score48b score53b, std item detail asis

*removing 48b
cap noi alpha score13b score14b score15b score16b score17b score20b ///
score23b score53b, std item detail asis

*removing 15b
cap noi alpha score13b score14b score16b score17b score20b ///
score23b score53b, std item detail asis

*resulting alpha:  0.9051, items: 7

*IN A: 54a, 22a, 15a, 17a, 18a, 14a, 19a
*IN B: 18b, 19b, 52b, 22b, 50b, 54b, 48b, 15b
*COMPOSITE: 54, 22, 18
*COMMON IN A AND B: 54, 22, 15, 18, 19

*SCORES WITH COMPOSITE AND MIXED VARIABLES
cap noi alpha score13 score14 score16 score17b score20 ///
score23 score48 score50 score52 score53, std item detail asis

*resulting alpha: 0.8773, items: 10

/*
POSSIBLE SCALE CONSTRUCTIONS FOR SOLUTIONS ORIENTED:
cap noi alpha score13 score14 score16 score17b score20 ///
score23 score48 score50 score52 score53, std item detail asis casewise
*resulting alpha: 0.8773, items: 10
cap noi alpha score13b score14b score16b score17b score20b ///
score23b score53b, std item detail asis
*resulting alpha: 0.9051, items: 7
*/

*INNOVATION SCORE USING COMPOSITE INDICATORS
cap noi alpha score24 score25 score26 score27 score28 score29 score30 score31 ///
score32 score52 score53 score55 score56, std item detail asis casewise

*removing 24
cap noi alpha score25 score26 score27 score28 score29 score30 score31 ///
score32 score52 score53 score55 score56, std item detail asis casewise

*removing 55
cap noi alpha score25 score26 score27 score28 score29 score30 score31 ///
score32 score52 score53 score56, std item detail asis casewise

*removing 56
cap noi alpha score25 score26 score27 score28 score29 score30 score31 ///
score32 score52 score53, std item detail asis casewise

*removing 32
cap noi alpha score25 score26 score27 score28 score29 score30 score31 ///
score52 score53, std item detail asis casewise

*resulting alpha: 0.8209, items: 9

*INNOVATIONS SCORE USING ALL QUESTIONS IN A
cap noi alpha score24a score25a score26a score27a score28a score29a score30a score31a ///
score32a score52a score53a score55a score56a, std item detail asis

*removing 24a
cap noi alpha score25a score26a score27a score28a score29a score30a score31a ///
score32a score52a score53a score55a score56a, std item detail asis

*removing 55a
cap noi alpha score25a score26a score27a score28a score29a score30a score31a ///
score32a score52a score53a score56a, std item detail asis

*removing 29a
cap noi alpha score25a score26a score27a score28a score30a score31a ///
score32a score52a score53a score56a, std item detail asis

*removing 30a
cap noi alpha score25a score26a score27a score28a score31a ///
score32a score52a score53a score56a, std item detail asis

*resulting alpha: 0.8229, items: 9

*INNOVATIONS SCORE USING ALL QUESTIONS IN B
cap noi alpha score24b score25b score26b score27b score28b score29b score30b score31b ///
score32b score52b score53b score55b score56b, std item detail asis

*removing 24b
cap noi alpha score25b score26b score27b score28b score29b score30b score31b ///
score32b score52b score53b score55b score56b, std item detail asis

*removing 56b
cap noi alpha score25b score26b score27b score28b score29b score30b score31b ///
score32b score52b score53b score55b, std item detail asis

*removing 32b
cap noi alpha score25b score26b score27b score28b score29b score30b score31b ///
score52b score53b score55b, std item detail asis

*removing 55b
cap noi alpha score25b score26b score27b score28b score29b score30b score31b ///
score52b score53b, std item detail asis

*removing 31b
cap noi alpha score25b score26b score27b score28b score29b score30b ///
score52b score53b, std item detail asis

*removing 52b
cap noi alpha score25b score26b score27b score28b score29b score30b ///
score53b, std item detail asis

*removing 28b
cap noi alpha score25b score26b score27b score29b score30b ///
score53b, std item detail asis

*resulting alpha: 0.9073, items: 6

*IN A: 24a, 55a, 29a, 30a
*IN B: 24b, 56b, 32b, 55b, 31b, 52b, 28b
*COMPOSITE: 24, 55, 56, 32
*COMMON IN A AND B: 24, 55

/*
POSSIBLE SCALE CONSTRUCTIONS FOR INNOVATIONS ORIENTED:
cap noi alpha score25b score26b score27b score29b score30b ///
score53b, std item detail asis
*resulting alpha: 0.9073, items: 6
*/

*GROWTH SCORE USING COMPOSITE INDICATORS
cap noi alpha score33 score34 score35 score36 score37 score38 score39 score40 score41 ///
score42 score49 score51 score54 score55, std item detail asis casewise

*removing 36
cap noi alpha score33 score34 score35 score37 score38 score39 score40 score41 ///
score42 score49 score51 score54 score55, std item detail asis casewise

*removing 54
cap noi alpha score33 score34 score35 score37 score38 score39 score40 score41 ///
score42 score49 score51 score55, std item detail asis casewise

*removing 42
cap noi alpha score33 score34 score35 score37 score38 score39 score40 score41 ///
score49 score51 score55, std item detail asis casewise

*removing 37
cap noi alpha score33 score34 score35 score38 score39 score40 score41 ///
score49 score51 score55, std item detail asis casewise

*removing 33
cap noi alpha score34 score35 score38 score39 score40 score41 ///
score49 score51 score55, std item detail asis casewise

*removing 34
cap noi alpha score35 score38 score39 score40 score41 ///
score49 score51 score55, std item detail asis casewise

*removing 49
cap noi alpha score35 score38 score39 score40 score41 ///
score51 score55, std item detail asis casewise

*removing 40
cap noi alpha score35 score38 score39 score41 ///
score51 score55, std item detail asis casewise
*resulting alpha: 0.7087, items: 6

*GROWTH SCORE USING ALL QUESTIONS IN A
cap noi alpha score33a score34a score35a score36a score37a score38a score39a score40a score41a ///
score42a score49a score51a score54a score55a, std item detail asis

*removing 54a
cap noi alpha score33a score34a score35a score36a score37a score38a score39a score40a score41a ///
score42a score49a score51a score55a, std item detail asis

*removing 33a
cap noi alpha score34a score35a score36a score37a score38a score39a score40a score41a ///
score42a score49a score51a score55a, std item detail asis

*removing 49a
cap noi alpha score34a score35a score36a score37a score38a score39a score40a score41a ///
score42a score51a score55a, std item detail asis

*removing 41a
cap noi alpha score34a score35a score36a score37a score38a score39a score40a ///
score42a score51a score55a, std item detail asis

*removing 34a
cap noi alpha score35a score36a score37a score38a score39a score40a ///
score42a score51a score55a, std item detail asis

*removing 51a
cap noi alpha score35a score36a score37a score38a score39a score40a ///
score42a score55a, std item detail asis

*removing 40a
cap noi alpha score35a score36a score37a score38a score39a ///
score42a score55a, std item detail asis

*removing 38a
cap noi alpha score35a score36a score37a score39a ///
score42a score55a, std item detail asis

*removing 37a
cap noi alpha score35a score36a score39a ///
score42a score55a, std item detail asis

*resulting alpha: 0.8360, items: 5

*GROWTH SCORE USING ALL QUESTIONS IN B
cap noi alpha score33b score34b score35b score36b score37b score38b score39b score40b score41b ///
score42b score49b score51b score54b score55b, std item detail asis

*removing 42b
cap noi alpha score33b score34b score35b score36b score37b score38b score39b score40b score41b ///
score49b score51b score54b score55b, std item detail asis

*removing 54b
cap noi alpha score33b score34b score35b score36b score37b score38b score39b score40b score41b ///
score49b score51b score55b, std item detail asis

*removing 36b
cap noi alpha score33b score34b score35b score37b score38b score39b score40b score41b ///
score49b score51b score55b, std item detail asis

*removing 41b
cap noi alpha score33b score34b score35b score37b score38b score39b score40b ///
score49b score51b score55b, std item detail asis

*removing 55b
cap noi alpha score33b score34b score35b score37b score38b score39b score40b ///
score49b score51b, std item detail asis

*removing 35b
cap noi alpha score33b score34b score38b score39b score40b ///
score49b score51b, std item detail asis

*removing 49b
cap noi alpha score33b score34b score38b score39b score40b ///
score51b, std item detail asis
*resulting alpha: 0.8410, items: 6

*IN A: 54a, 33a, 49a, 41a, 34a, 51a, 40a, 38a, 37a
*IN B: 42b, 54b, 36b, 41b, 55b, 35b, 49b
*COMPOSITE: 36, 54, 42, 37, 33, 34, 49, 30
*COMMON IN A AND B: 54, 49, 41

*SCORES WITH COMPOSITE AND MIXED VARIABLES
cap noi alpha score33b score34b score35 score36 score37b score38b score39 score40b ///
score42 score51b score55, std item detail asis

*removing 36
cap noi alpha score33b score34b score35 score37b score38b score39 score40b ///
score42 score51b score55, std item detail asis

*removing 42
cap noi alpha score33b score34b score35 score37b score38b score39 score40b ///
score51b score55, std item detail asis

*resulting alpha:  0.7931, items: 9

/*
POSSIBLE SCALE CONSTRUCTIONS FOR GROWTH ORIENTED:
cap noi alpha score33b score34b score35 score37b score38b score39 score40b ///
score51b score55, std item detail asis
*resulting alpha: 0.7931, items: 9
cap noi alpha score33b score34b score38b score39b score40b ///
score51b, std item detail asis
*resulting alpha: 0.8410, items: 6
*/

*MORE REFINEMENT IN SCALE LOOKING AT INTERITEM CORRELATIONS

*FOR PEOPLE
cap noi alpha score1b score2b score4 score5 score6b score7b score8b ///
score11 score12 score48 score51, std item detail asis

*removing 1b
cap noi alpha score2b score4 score5 score6b score7b score8b ///
score11 score12 score48 score51, std item detail asis
*resulting alpha: 0.8523 items: 10

*FOR GROWTH

cap noi alpha score33b score34b score35 score37b score38b score39 score40b ///
score51b score55, std item detail asis
*removing 55
cap noi alpha score33b score34b score35 score37b score38b score39 score40b ///
score51b, std item detail asis
*resulting alpha: 0.7867, items: 8


cap noi alpha score33b score34b score38b score39b score40b ///
score51b, std item detail asis
*removing 39b
cap noi alpha score33b score34b score38b score40b ///
score51b, std item detail asis
*resulting alpha: 0.8287, items: 5

*POTENTIAL SCALES AND RESULTING STANDARDIZED SCORES

*For People
cap noi alpha score2b score4 score5 score6b score7b score8b ///
score11 score12 score48 score51, std item detail asis gen(people_stdsc)
hist people_stdsc

*For solutions
cap noi alpha score13 score14 score16 score17b score20 ///
score23 score48 score50 score52 score53, std item detail asis gen(sol_stdsc1)
hist sol_stdsc1

cap noi alpha score13b score14b score16b score17b score20b ///
score23b score53b, std item detail asis gen(sol_stdsc2)
hist sol_stdsc2

*For Innovations
cap noi alpha score25b score26b score27b score29b score30b ///
score53b, std item detail asis gen(inn_stdsc)
hist inn_stdsc

*For Growth
cap noi alpha score33b score34b score35 score37b score38b score39 score40b ///
score51b score55, std item detail asis gen(gr_stdsc1)
hist gr_stdsc1

cap noi alpha score33b score34b score38b score39b score40b ///
score51b, std item detail asis gen(gr_stdsc2)
hist gr_stdsc2
