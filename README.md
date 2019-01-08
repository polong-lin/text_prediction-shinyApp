# Report on Creating a Predictive Text App using text mining libraries and Shiny

<div id="header">
<h1 class="title">Report on Creating a ‘Predictive Text App’ using text mining libraries and Shiny</h1>
<h4 class="author"><em>Polong Lin</em></h4>
<h4 class="date"><em>October 12, 2014</em></h4>
</div>


<p><br></p>
<div id="summary-of-report" class="section level2">
<h2>Summary of report:</h2>
<p>In this report, I discuss my creation of a predictive text app that trained on a large corpus of text from news-related sources. I discuss how the data was used to create n-gram models, that were subsequently used to generate my first prediction model, using a <em>very</em> simplified version of the Katz-Backoff model. Next, I tried to implement the Kneser-Ney smoothing algorithm, but due to limited time to process the scripts, the results were not as ideal as hoped. Both prediction models are shown in a final Shiny app.</p>
<div id="shiny-app-httppolonglin.shinyapps.iotext-prediction" class="section level3">
<h3>Shiny app: <a href="http://polonglin.shinyapps.io/text-prediction">http://polonglin.shinyapps.io/text-prediction</a></h3>
</div>
</div>
<div id="introduction" class="section level2">
<h2>Introduction:</h2>
<p>The purpose of this project was to create a predictive text app that predicts the next word that follows a sentence input. For example, given “I can not wait to” as the input sentence, the app should suggest words like “see”, “go”, and “eat”.</p>
<p>This report is broken down into the <strong>two major steps</strong>:</p>
<ol style="list-style-type: decimal">
<li>Training the app on a large corpus of text
<ul>
<li>importing the corpus</li>
<li>cleaning the corpus to remove undesired items</li>
<li>converting the corpus into a proper format (data tables of n-gram models)</li>
</ul></li>
<li>Generating the predictions
<ul>
<li>smoothing the n-gram model</li>
<li>retrieving predictions</li>
</ul></li>
</ol>
<hr>

</div>
<div id="training-the-app-on-a-large-corpus-of-text" class="section level2">
<h2>1. Training the app on a large corpus of text</h2>
<div id="overall-process" class="section level4">
<h4><strong>Overall Process:</strong></h4>
<ol style="list-style-type: decimal">
<li><p>Import the corpus (or a subset of say, 500,000 lines, as I did)</p></li>
<li><p>Clean the text (e.g., remove symbols, emoticons, profanity)</p></li>
<li><p>Tokenize the text</p></li>
<li><p>Create a data table of a unigram model with the token and token counts as the columns</p></li>
<li><p>Repeat #4 for higher n-grams, up until 5-gram.</p></li>
<li><p>Add columns to split each token into its individual words, for better indexing (e.g., token1, token2, token, and count as the columns of a data table for the bigram model).</p></li>
<li><p>Remove any tokens with a count of 1 from each model to reduce size.</p></li>
</ol>
<hr>

</div>
<div id="a.-corpus-source" class="section level4">
<h4>a. Corpus Source:</h4>
<p>There were three corpi available in English: text that was mined from <em>Twitter</em>, from <em>blogs</em>, and from <em>news articles</em> online. One can download all of the text files used in this project at:</p>
<p><a href="https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip">https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip</a></p>
</div>
<div id="summary-statistics-of-data-sources-blog-news-twitter" class="section level4">
<h4>Summary Statistics of data sources (blog, news, Twitter)</h4>
<p>Twitter data: 2.3610^{6} lines of text; NA MB</p>
<p>Blog data: 910^{5} lines of text; NA MB</p>
<p>News data: 1.0110^{6} lines of text; NA MB</p>
<p><strong>Note:</strong> Although I worked on all three datasets, all of the code in this report uses the “News” data set.</p>
<p>Example of text from the news corpus:</p>
<pre><code>## He wasn't home alone, apparently.</code></pre>
<pre><code>## The St. Louis plant had to close. It would die of old age. Workers had been making cars there since the onset of mass automotive production in the 1920s.</code></pre>
</div>
<div id="b.-creating-n-gram-models" class="section level4">
<h4>b. Creating n-gram models</h4>
<p>Natural language processing (NLP) is a field that is concerned with using computer science to analyze text. Borrowing from concepts in NLP, we divided each text document into tokens (i.e., individual words in this case), which could be grouped into n-grams for analysis. N-grams are words that occur consecutively, with “n” representing the number of words in question. For example, trigrams are triplets of words together. Bigrams are pairs of words. Unigrams are individual words. By “tokenizing” a corpus, we can take tokens that occur together, and gather the number of times each n-gram occurs throughout the corpus (e.g., the number of times the trigram, “it is the”, occurs in the text).</p>
<p>Thus, for each n in n-gram, the corpus of text was converted into counts of n-gram. Here is an example of the <strong>final product</strong>:</p>
<pre><code>## The most common bigrams from the news corpus
##   token1: first word in the bigram
##   token2: second word in the bigram
##   token: the bigram
##   count: the number of items the bigram appeared</code></pre>
<pre><code>##    token1 token2   token count
## 1:     of    the  of the 79156
## 2:     in    the  in the 76945
## 3:     to    the  to the 38823
## 4:     on    the  on the 33406
## 5:    for    the for the 32076
## 6:     it     is   it is 31614</code></pre>
<hr>

</div>
<div id="c.-explanation-of-how-i-created-the-n-gram-models-in-r" class="section level4">
<h4>c. Explanation of how I created the n-gram models in R</h4>
<p>The text was imported using <code>readLines</code>, and converted into a corpus using the <code>tm</code> package in R.</p>
<pre><code>require(tm)
sourcename = &quot;news&quot;; lines = 500000
readLines(paste0(directory,&quot;/final/en_US/en_US.&quot;,sourcename,&quot;.txt&quot;),
              n = lines))
cleanedCorpus &lt;- cleanCorpus(Corpus(VectorSource(text)))</code></pre>
<p><code>cleanCorpus</code> is a custom function I built to pre-process the text. The purpose was the following:</p>
<ul>
<li><strong>remove most symbols</strong> such as #%$, because they do not add any value to word predictions</li>
<li><strong>convert “!” and “?”&quot; to “.”</strong> to signify the end of a sentence</li>
<li><strong>reduce consecutive periods</strong> into a single period</li>
<li><strong>convert “&amp;” symbol into “and”</strong> as they mean the same thing</li>
<li><strong>remove profanity</strong> based on a list of words from a separate text file. This list was obtained from: <a href="https://raw.githubusercontent.com/shutterstock/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words/master/en">https://raw.githubusercontent.com/shutterstock/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words/master/en</a></li>
<li><strong>remove numbers</strong> “0123456789”&quot; to simplify the corpus</li>
<li><strong>convert all text to lowercase</strong> for simplicity</li>
<li><strong>expand contractions</strong> so that contractions can be tokenized as if they were the same as their full forms</li>
<li><strong>remove extra whitespace</strong></li>
</ul>
<hr>

<p>Next, the text were <strong>tokenized</strong> using <code>tau</code> or the <code>RWeka</code> packages, which were interchangeable.</p>
<pre><code>require(tau)
tau_ngrams &lt;- function(x, ngrams) return(rownames(as.data.frame(unclass(textcnt(x,method=&quot;string&quot;,n=ngrams)))))</code></pre>
<pre><code>clean.tdm &lt;- TermDocumentMatrix(cleanedCorpus, 
                                control = list(tokenize = function(x) tau_ngrams(x, ngrams),
                                               wordLengths = c(1, Inf)
                                               ))</code></pre>
<p>Next, <strong>data tables were created</strong> for each ngram model.</p>
<pre><code>ngram_model &lt;- rollup(clean.tdm, 2, na.rm = TRUE, FUN = sum)
ngram_model_dt &lt;- data.table(token = ngram_model$dimnames$Terms, count = ngram_model$v)</code></pre>
<p>After splitting the tokens, which contained multiple words, into a word per column, this resulted in our <strong>final n-gram model output</strong>.</p>
<p>Here’s an example:</p>
<p><strong>The final output for a trigram model:</strong></p>
<pre><code>##            token1    token2 token3                  token count
##       1:      one        of    the             one of the  7019
##       2:        a       lot     of               a lot of  5196
##       3:       it        is      a                it is a  4809
##       4:        i        do    not               i do not  3693
##       5:       it        is    not              it is not  3206
##      ---                                                       
## 1397053:   zydeco        or  cajun        zydeco or cajun     2
## 1397054: zydrunas ilgauskas    was zydrunas ilgauskas was     2
## 1397055:     zygi      wilf   said         zygi wilf said     2
## 1397056:    zynga         s  other          zynga s other     2
## 1397057:       zz       top      s               zz top s     2</code></pre>
<p><em>As you can see above, there are some trigrams with words that do not appear to be actual English words. This shows how my functions used to clean the corpus can still improve. In the end, I decided to spend more time working on the next phase of producing the prediction algorithm, rather than spending too much time to generate a cleaner corpus!</em></p>
<hr>

</div>
</div>
<div id="generating-the-predictions" class="section level2">
<h2>2. Generating the predictions</h2>
<p>Based on the data tables and their counts, I was now able to create a very simple prediction model.</p>
<div id="a.-prediction-model-1-using-raw-counts" class="section level3">
<h3>a. Prediction model 1: Using raw counts</h3>
<p>This basic prediction model is best summarized as a simplified version of the Katz’s back-off model. For a given sentence with <code>k</code> words, it returns <code>k+1</code>th words that have the highest counts according to the <code>k+1</code>-gram data table. 1. Input a sentence. 2. Reduce the sentence to the final <code>k</code> words, where <code>k</code> is the number of n-gram models created minus one. 3. Check the n-gram data table and match the <code>n-1</code> words to return a list of <code>n</code>th words, according to the data table. 4. If Step 3 returns at least one word, then the prediction stops here. Otherwise, if no <code>n</code>th word was found, then it reduces the sentence of <code>k</code>-words into <code>k-1</code>-words and repeats #3. 5. Still, if no words are found at the bigram level (e.g., no continuation of the final word, “to”) then the prediction model does not return any words.</p>
<hr>

<div id="heres-an-example-of-the-algorithm-in-prediction-1" class="section level4">
<h4>Here’s an example of the algorithm in Prediction 1:</h4>
<p>We begin with a string:</p>
<pre class="r"><code>string &lt;- tolower(&quot;The most advanced vehicle of the&quot;)
string &lt;- strsplit(string, &quot; &quot;)[[1]]
string</code></pre>
<pre><code>## [1] &quot;the&quot;      &quot;most&quot;     &quot;advanced&quot; &quot;vehicle&quot;  &quot;of&quot;       &quot;the&quot;</code></pre>
<pre class="r"><code>length(string)</code></pre>
<pre><code>## [1] 6</code></pre>
<hr>

<p>Then we reduce the string to the final k words, where k is equal to the number of ngram models minus one.</p>
<pre class="r"><code>k &lt;- length(ndictlist) - 1 #Number of n-gram models in &quot;ndictlist&quot; minus one
string &lt;- tail(string, k) #Reducing the string
string</code></pre>
<pre><code>## [1] &quot;vehicle&quot; &quot;of&quot;      &quot;the&quot;</code></pre>
<hr>

<p>Then we look up the highest n-gram model to see what candidate <code>n</code>th words are returned:</p>
<pre class="r"><code>setkey(ndictlist[[4]], token1, token2, token3)
result &lt;- ndictlist[[4]][list(string[1], string[2], string[3])]
result[order(-count)]</code></pre>
<pre><code>##     token1 token2 token3 token4 token count
## 1: vehicle     of    the     NA    NA    NA</code></pre>
<p>As we can see, there are <em>no possible candidate words</em> that follow to <code>&quot;vehicle of the&quot;</code>. These words are returned because they were found in the original news corpus. So what we are seeing in the data table above is the ranking of the most popular endings to <code>&quot;vehicle&quot;</code> found in the news corpus, <strong>of which there were none</strong>.</p>
<hr>

<p>Next, the prediction models reduces the sentence by one and re-iterates the process.</p>
<pre class="r"><code>k &lt;- k - 1 #Number of n-gram models in &quot;ndictlist&quot; minus one
string &lt;- tail(string, k) #Reducing the string
string</code></pre>
<pre><code>## [1] &quot;of&quot;  &quot;the&quot;</code></pre>
<pre class="r"><code>setkey(ndictlist[[3]], token1, token2)
result &lt;- ndictlist[[3]][list(string[1], string[2])]
result[order(-count)][1:10]</code></pre>
<pre><code>##     token1 token2 token3         token count
##  1:     of    the   year   of the year  1656
##  2:     of    the season of the season  1262
##  3:     of    the   most   of the most  1187
##  4:     of    the  state  of the state   954
##  5:     of    the    new    of the new   830
##  6:     of    the  world  of the world   799
##  7:     of    the   city   of the city   773
##  8:     of    the   game   of the game   744
##  9:     of    the   best   of the best   666
## 10:     of    the  first  of the first   644</code></pre>
<p>The trigram model was able to find trigrams beginning with <code>&quot;of the&quot;</code> and returned the results above.</p>
<hr>

<p>Indeed, there are a number of drawbacks to this model: - it would have to train on an extremely large corpus to be able to retrieve all the valid combinations (n-grams) of words - a few n-grams occur very frequently, while most n-grams appear seldomly. There is no discounting applied to the counts to even out the distribution. - it can not handle combinations of words it has never seen before in the corpus</p>
<p>**For these reasons, I decided to try a prediction model using the Kneser-Ney method.</p>
</div>
</div>
<div id="b.-prediction-model-2-my-attempt-at-kneser-ney-smoothing" class="section level3">
<h3>b. Prediction Model 2: My attempt at Kneser-Ney smoothing</h3>
<p>Kneser-Ney smoothing is an algorithm designed to adjust the weights (through discounting) by using the continuation counts of lower n-grams. The concept is fairly simple though a bit more difficult to implement in a program than the one used in Prediction Model 1.</p>
<p>Given the sentence, “Francisco”&quot; is presented as the suggested ending, because it appears more often than “glasses” in some text.</p>
<blockquote>
<p>I can’t see without my reading… __ Francisco __</p>
</blockquote>
<p>However, even though “Francisco” appears more often than “glasses”, “Francisco” rarely occurs outside of the context of “San Francisco”. Thus, instead of observing how often a word appears, the Kneser-Ney algorithm takes into account how often a word completes a bigram type (e.g., “prescription glasses”, “reading glasses”, “small glasses” vs. “San Francisco”). This example was taken from Jurafsky’s video lecture on Kneser-Ney Smoothing, which also describes the equation used to calculate the Kneser-Ney probability. <a href="https://www.youtube.com/watch?v=wtB00EczoCM">https://www.youtube.com/watch?v=wtB00EczoCM</a></p>
<p>I believe that typically, the smoothing algorithm is performed on all of the n-grams (unigram models, bigram models, etc.) <em>prior</em> to attempting any predictions. However, given the restraint of computing time, I only had enough time to create a version which performs the smoothing when a user provides an input.</p>
<hr>

<p>I was able to write a <strong>completely recursive</strong> Kneser-Ney algorithm, <code>pkn.calc</code>, for n-gram models of any n. However, in effect, I limited the number of candidate words and thus the resulting term is often very inaccurate.</p>
<p>The procedure of my <code>pkn.calc</code> function is as follows:</p>
<ol style="list-style-type: decimal">
<li>Calculate the Kneser-Ney probability (PKN) of the lowest order (unigram level).</li>
<li>Calculate the PKN of all the lower orders using successively lower PKN values.</li>
<li>Calculate the highest PKN value using the PKN of the lower values, and return this value.</li>
</ol>
<p>To implement this in real-time means I first select the candidates (what words could come next in a sentence) to be used for smoothing.</p>
<p>The candidates for what word should come next are chosen as the top-ranking words to follow <code>wi</code> in the bigram mode, where the first word of the bigram is the final word (word i, or <code>wi</code> for short).</p>
<p>For example, I would take the top 50 words to follow “of” to be used as candidates to calculate which had the highest PKN value.</p>
<pre class="r"><code>string &lt;- &quot;vehicle of the&quot;
dictlist &lt;- ndictlist

source(&quot;predictive-text-analysis/pkn/pkn.candidateList.R&quot;)
candidateList &lt;- candidateList(string, dictlist, min = 2)
head(candidateList, n = 10)</code></pre>
<pre><code>##  [1] &quot;first&quot;   &quot;state&quot;   &quot;same&quot;    &quot;city&quot;    &quot;new&quot;     &quot;most&quot;    &quot;company&quot;
##  [8] &quot;us&quot;      &quot;last&quot;    &quot;best&quot;</code></pre>
<hr>

<p>Using all of the words in <code>candidateList</code>, I calcuated the pkn value for each, producing the following table:</p>
<pre class="r"><code>#PKN calculation (fully recursive)
source(&quot;predictive-text-analysis/pkn/pkn.pkn.calc.R&quot;)

results &lt;- c()
for(q in 1:length(head(candidateList))){
    temp &lt;- pkn.calc(string, candidate = head(candidateList)[q], dictlist)
    results &lt;- c(results, temp)
    names(results)[q] &lt;- head(candidateList)[q]
}
pkn.results.sorted &lt;- sort(results, decreasing = TRUE)
pkn.results.df &lt;- data.frame(&quot;pkn&quot; = pkn.results.sorted, &quot;rank&quot; = 1:length(pkn.results.sorted))
pkn.results.df</code></pre>
<pre><code>##               pkn rank
## most  0.015240435    1
## state 0.012619176    2
## new   0.010971481    3
## city  0.010297586    4
## first 0.008547671    5
## same  0.004329523    6</code></pre>
<p>As you can see above, these seem to be less ideal than the candidates seen from Prediction Model 1, which used raw counts. <strong>Certainly this model needs to be tweaked - by not limiting the pkn calculations to the candidates used.</strong></p>
<p>Nonetheless, this is as much as I was able to do within the timeframe of this project.</p>
<hr>

</div>
</div>
<div id="comparing-the-two-models" class="section level2">
<h2>Comparing the two models</h2>
<p>Two models were used:</p>
<ol style="list-style-type: decimal">
<li>Raw counts based on n-grams that already exist in the corpus.</li>
<li>Kneser-Ney probabilities based on candidates (the possible bigram continuations for the final word in the sentence)</li>
</ol>
<p>Here are the two results for <code>vehicle of the _____</code></p>
<pre class="r"><code>## Prediction Model 1: Using raw counts
result[order(-count)][1:6][, c(&quot;token3&quot;, &quot;count&quot;), with=FALSE]</code></pre>
<pre><code>##    token3 count
## 1:   year  1656
## 2: season  1262
## 3:   most  1187
## 4:  state   954
## 5:    new   830
## 6:  world   799</code></pre>
<pre class="r"><code>## Prediction Model 2: Using Kneser-Ney smoothing
pkn.results.df</code></pre>
<pre><code>##               pkn rank
## most  0.015240435    1
## state 0.012619176    2
## new   0.010971481    3
## city  0.010297586    4
## first 0.008547671    5
## same  0.004329523    6</code></pre>
<p>As you can tell, both prediction models are not producing words that are related to “vehicle”. In fact, “vehicle of the” does not appear in the corpus, as I pointed out in the Prediction Model 1.</p>
<p>However, Prediction Model 1 seems to be producing better prediction results than Prediction Model 2.</p>
</div>
<div id="conclusion" class="section level2">
<h2>Conclusion</h2>
<p>I created two prediction models to try to predict the next word of a sentence. The simpler version, using raw counts, appears to work better, but the second, which uses the Kneser-Ney algorithm, if implemented correctly, is also promising.</p>
<p>More work needs to be done on optimizing processing speed as well. For example, much of the Kneser-Ney smoothing can be done in parallel, across several nodes.</p>
<p>Overall, this project was a significant educational experience where I learned to deal with large amounts of data, to process textual data, and I learned how to explore algorithms to optimize predictive power.</p>
</div>


</div>

<script>

// add bootstrap table styles to pandoc tables
$(document).ready(function () {
  $('tr.header').parent('thead').parent('table').addClass('table table-condensed');
});

</script>

<!-- dynamically load mathjax for compatibility with self-contained -->
<script>
  (function () {
    var script = document.createElement("script");
    script.type = "text/javascript";
    script.src  = "https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML";
    document.getElementsByTagName("head")[0].appendChild(script);
  })();
</script>

</body>
</html>
