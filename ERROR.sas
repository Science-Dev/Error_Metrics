/* Macro to calculate Mean Absolute Eror and Root Mean Squared Error */
/* Outputs to data set, log, and macro variable */
%macro mae_rmse(
        dataset /* Data set which contains the actual and predicted values */, 
        actual /* Variable which contains the actual or observed valued */, 
        predicted /* Variable which contains the predicted value */
        );
%global mae rmse ef; /* Make the scope of the macro variables global */
  data &dataset;
    /* retain square_error_sum abs_error_sum; */
    retain actual_mean;
    set &dataset 
        end=last /* Flag for the last observation */ 
        ; 
    if _n_ = 1 then do;
    actual_mean = mean(&actual); /* Calculate actual mean */
    end;
    error_den = &actual - actual_mean; /* Calculate simple error */
    square_error_den = error_den * error_den; /* error_den^2 */
    error = &actual - &predicted; /* Calculate simple error */
    square_error = error * error; /* error^2 */
    if _n_ eq 1 then do;
        /* Initialize the sums */
        square_error_sum_den = square_error_den; 
        square_error_sum = square_error; 
        abs_error_sum = abs(error); 
        end;
    else do;
        /* Add to the sum */
        square_error_sum_den = square_error_sum_den + square_error_den; 
        square_error_sum = square_error_sum + square_error; 
        abs_error_sum = abs_error_sum + abs(error);
    end;
    if last then do;
        /* Calculate RMSE, MAE and EF store in SAS data set. */
        mae = abs_error_sum/_n_;
        rmse = sqrt(square_error_sum/_n_); 
        ef = (1-(square_error_sum/square_error_sum_den))*100;
        /* Write to SAS log */
        /* put 'NOTE: ' mae= rmse=; */
        /* Store in SAS macro variables */
        /* call symput('mae', put(mae, 20.10)); 
        call symput('rmse', put(rmse, 20.10)); */
        end;
run;
%mend;
 
/* Alternative macro that uses PROC SQL.  Output is only a macro variable */
%macro mae_rmse_ef(
        dataset /* Data set which contains the actual and predicted values */, 
        actual /* Variable which contains the actual or observed valued */, 
        predicted /* Variable which contains the predicted value */,
        actual_m /* Variable which contains the actual mean value */
        );
%global mae rmse ef; /* Make the scope of the macro variables global */
proc sql noprint;
    select count(1) into :count from &dataset;
    select mean(abs(&actual-&predicted)) format 20.10 into :mae from &dataset;
    select sqrt(mean((&actual-&predicted)**2)) format 20.10 into :rmse from &dataset;
    select ((1-(mean((&actual-&predicted)**2)/mean((&actual-&actual_m)**2)))*100) format 20.10 into :ef from &dataset;
quit;
%mend;