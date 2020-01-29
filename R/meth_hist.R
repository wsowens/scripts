#!/usr/bin/env Rscript

# Copyright 2020 William Owens
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# script to get the methylation frequency

library(ggplot2)
filenames <- commandArgs(trailingOnly = TRUE)
output <- file("meth_summary.csv", "w")
write("filename,avg_meth,total_sites,sites >= 10x cov", output, append=TRUE)
make_graph <- function(filename, cov = 0) {
	bed <- try(read.csv(filename, sep = "\t", head = FALSE))
    if (class(bed) == "try-error") {
        write(paste(filename, "NULL", 0, 0, sep=","), output, append=TRUE)
        print("error")
        return()
    } else {
        print("all good")
    }
    print("continuing")
	avg_meth <- mean(bed[[4]])
	png(sprintf("%s%s", filename, ".png"), width = 1280, height = 720)
	ggplot(data.frame(meth_rate = bed$V4), aes(x=meth_rate)) + 
		geom_histogram(breaks = 1:100 / 100) +
		ggtitle(sprintf("%s (avg = %.6f)", filename, avg_meth)) +
		theme_bw(base_size = 16) +
		theme(plot.title = element_text(hjust = 0.5))
	print(last_plot())
	dev.off()
    total_sites <- nrow(bed)
    tenx_sites <- sum(bed$V5 >= 10)
    write(paste(filename, avg_meth, total_sites, tenx_sites, sep=","), output, append=TRUE)
}

for (fn in filenames) {
  make_graph(fn)
}
close(output)
