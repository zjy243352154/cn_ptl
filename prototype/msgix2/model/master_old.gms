
DON'T use this file for the new version.
The file is incomplete: it contains ONLY the elements that should be
added (considered) for the new version of master.gms;
the latter file should be derived from the file that is the argument
of the gams cmd when gams is run from the cmd-line.
Given the example just below it is most probably MESSAGE_run.gms

***
* - directly from the command line, with the input data file name
*   and other options specific as command line parameters, e.g.::
*
*   ``gams MESSAGE_run.gms --in="<data-file>" [--out="<output-file>"]``
*

*** the below cmd should be added in order to NOT use the --in
* option of the cmd-line call
$setglobal in data/params.gdx
;


*** the first line should be in the MESSAGE_run.gms, the second has
to be added to include the model_mca.gms file
$INCLUDE MESSAGE/model_setup.gms
$INCLUDE model_mca.gms

*** The following lines should be added (below the above two lines)
* for the reasons explained below
* Handling of the time periods 
$ontext
In the message_ix generated model handling of time periods is done in
model_solve.gms (prior to the optimization). In MCMA model_solve.gms
is not used. Therefore, the following xxx lines were copied here.
$offtext
* reset year in case it was set by MACRO to include the base year before
* include all model periods in the optimization horizon (excluding
* historical periods prior to 'first_period')
    year(year_all) = no ;
    year(year_all)$( model_horizon(year_all) ) = yes ;

*** NOTe: The line below is NOT commented in the original file 
*   $INCLUDE MESSAGE/model_solve.gms
* but it MUST be commented in the version for MCMA
*
* Skip the model_solve.gms --------------------------------------------
* solve statements (including the loop for myopic or rolling-horizon
* optimization) skipped
*   $INCLUDE MESSAGE/model_solve.gms

* run MCMA, if the --mcma option used in the gams cmd-line 
* the mcma value specifies the file name generated by the MCMA.
* The file contains the MCMA variables and relations, as well as the gams
* "Solve" statement.
$If set mcma $INCLUDE %mcma%
$If set mcma $GOTO post_solve

$ontext
The remaining (up to the post_solve label) statements are used for
testing the generated model by using single-criterion optimization for
each of the defined outcome variable defined to be used as one of the
criteria. The OBJ is the predefined (by message_ix) objective. The
other variables (CO2_CUM, COST_CUM) are defined in the cn_ptl model
prototype. The latter list shall be extended in the forthcoming versions
of the model.
$offtext

Model MC_lp / all / ;
* The following options might be used in future. Currently are not
* generated by the MCMA; therefore, for the compatibility, are commented.
* MC_lp.holdfixed = 1 ;
* MC_lp.optfile = 1 ;
* MC_lp.optcr = 0 ;
* Write a status update to the log file, solve the model.
* Note: the gdx output will be available only for the last optimization.
* Comment/uncomment pairs of the below statements to optimize the desired
* outcome/criterion variable.
* Comment/uncomment the Display statements that store values in master.log

*	put_utility 'log' /'+++ Minimize OBJ variable. +++ ' ;
*	Solve MC_lp using LP minimizing OBJ ;

* the next 4 lines should remain/be uncommented for CO2 minimization
	put_utility 'log' /'+++ Minimize CO2_CUM variable. +++ ' ;
	Solve MC_lp using LP minimizing CO2_CUM ;
	Display CO2_CUM.l ;
	Display COST_CUM.l ;

* the next 4 lines should remain/be uncommented for COST minimization
*	put_utility 'log' /'+++ Minimize COST_CUM variable. +++ ' ;
*	Solve MC_lp using LP minimizing COST_CUM ;
*	Display CO2_CUM.l ;
*	Display COST_CUM.l ;

	put_utility 'log' /'+++ After the Solve +++ ' ;


$LABEL post_solve

***  continue with the message_ix postprocessing
* Note: the part of postprocessing (included in model_solve.gms)
* is currently not included in this version.

*----------------------------------------------------------------*
* post-processing and export to gdx   
*----------------------------------------------------------------*

* include MESSAGE GAMS-internal reporting
$INCLUDE MESSAGE/reporting.gms

* dump all input data, processed data and results to a gdx file
execute_unload "%out%"

put_utility 'log' / /"+++ End of MCMA - MESSAGEix run +++ " ;

*------------------------------------------------------------*
* end of file - have a nice day!                             *
*----------------------------------------------------------- *
