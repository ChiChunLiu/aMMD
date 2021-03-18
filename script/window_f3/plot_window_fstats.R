library(tidyverse)
library(ggplot2)
library(data.table)
library(biomaRt)
setwd('/project/jnovembre/chichun/um_unadmixed/window_fstat')

#### define functions ####
blk = read_tsv('/project2/jnovembre/old_project/chichun/ancient-tbtn-analysis/data/input/LDblock/fourier_ls_asn-all.bed')
blk$chr = as.numeric(sapply(blk$chr, function(x) strsplit(x,'chr')[[1]][2]))

get_peak_genes = function(f3_df, npeak = 20, blk = blk){
  # one region per ld block
  f3_df[, block := 0]
  i = 1
  for (i in 1:nrow(blk)) f3_df[chr == blk[i,chr] & pos > blk[i,start] & pos < blk[i,stop], block := i]
  f3_df = f3_df[block != 0]
  peak = f3_df[, .SD[which.max(f3)], by = block][order(f3, decreasing = T)][1:npeak]
  # query genes in the peak regions
  ensembl = useMart(biomart="ENSEMBL_MART_ENSEMBL", host="grch37.ensembl.org", path="/biomart/martservice", dataset="hsapiens_gene_ensembl")
  f3_genes = getBM(attributes = c('hgnc_symbol', 'chromosome_name', 'start_position', 'end_position'), 
                   filters = 'chromosomal_region', 
                   values = paste(peak$chr, peak$start_pos, peak$start_pos+200000,sep = ":"), 
                   mart = ensembl)
  return(as.data.table(f3_genes)[hgnc_symbol != ""])
}

plot_whole_genome <- function(df, m, M, title = ""){
  
  d.mutated <- df %>% 
    
    # Compute chromosome size
    group_by(chr) %>% 
    summarise(chr_len = max(pos)) %>% 
    
    # Calculate cumulative position of each chromosome
    mutate(tot = cumsum(chr_len) - chr_len) %>%
    dplyr:::select(- chr_len) %>%
    
    # Add this info to the initial dataset
    left_join(df, ., by=c("chr"="chr")) %>%
    
    # Add a cumulative position of each SNP
    arrange(chr, pos) %>%
    mutate( pos_cum= pos + tot)
  
  
  axisdf = d.mutated %>% group_by(chr) %>% summarize(center=( max(pos_cum) + min(pos_cum) ) / 2)
  
  
  p <- ggplot(d.mutated, aes(x = pos_cum, y = f)) +
    ylim(m, M) +
    # Show all points
    geom_point( aes(color = as.factor(chr)), alpha=0.8, size=1.3) +
    scale_color_manual(values = rep(c("#ef8a62", "#67a9cf"), 22 )) +
    
    # custom X axis:
    scale_x_continuous(label = axisdf$chr, breaks= axisdf$center) +
    #scale_y_continuous(expand = c(0, 0)) +     # remove space between plot area and x axis
    
    # Custom the theme:
    theme_bw() +
    xlab('chromosome') +  ggtitle(title) +
    theme( 
      legend.position="none",
      plot.title = element_text(hjust = 0.5),
      panel.border = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_blank()
    ) 
  return(p)
}

plot_single_chromosome <- function(df, chrom, m, M, title = ""){
  p <- ggplot(aes(x = pos/10^6, y = f),data = df[chr == chrom]) + 
    geom_point() + xlab('pos(Mb)') + ylim(m, M) + ggtitle(title)
  return(p)
}

retrieve_population = function(fstat_df, pop){
  fstat = fstat_df %>% select(chr, pos, !!pop)
  names(fstat) <- c('chr', 'pos', 'f')
  fstat = fstat[is.na(f)==0]
  return(fstat)
}

#### plot whole genome f3 statistics ####
f3s = read_tsv('output/window_fstats/TIB_CHB_aACA.chr2.window_f3.txt.gz')

f3 = retrieve_population(f3s, 'aACA_merged')
plot_whole_genome(f3_input, -.005, max(f3_input$f), title = 'modern f3: f3(TIB; aACA, CHB)')

#### find genes in peaks ####
mod_genes = get_peak_genes(f3s, 30)

###########################################################
plot_single_chromosome(f3s, 2, min(f3s$f3), max(f3s$f3))


###########################################################



f3s
