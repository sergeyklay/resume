%% resume.cls -- a two-page academic-register resume class for pdfLaTeX.
%%
%% Engine:  pdfLaTeX only (microtype expansion/tracking/kerning/spacing are
%%          unavailable under XeLaTeX and only partly available under LuaLaTeX).
%% Base:    article, 11pt, a4paper.  Strict monochrome.  No icons, no photo.
%%
%% Public interface -- one line per command:
%%
%%   \name{Full Name}                       declares the author; drives header,
%%                                          page footer and PDF metadata.
%%   \headline{Professional headline}       optional one-line subtitle under the
%%                                          name; also becomes the PDF subject.
%%   \contact{text}                         adds one plain item to the contact
%%                                          line; repeat for each item.
%%   \contact[url]{text}                    same, but hyperlinked to url
%%                                          (black and clickable, never coloured).
%%   \makeheader                            typesets name, headline, contact line
%%                                          and the rule below them.
%%   \section{Title}                        spaced small-caps heading with a thin
%%                                          rule under it; unnumbered.
%%   \role{title}{org}{location}{period}    employment entry: bold title with the
%%                                          period flush right, italic organisation
%%                                          and location on the line below.
%%   \project{name}{urltext}{role}{period}  open-source entry: bold project name
%%                                          with the period flush right, role and
%%                                          linked url on the line below.
%%   \record{left}{right}                   one-line entry, left text with right
%%                                          text flush right; no sub-line.
%%   \skills{label}{list}                   one row of the skills block: small-caps
%%                                          label in a fixed-width column, list
%%                                          set ragged right beside it.
%%   \note{text}                            small-type run-on remark, e.g. a
%%                                          collapsed "Earlier roles: ..." line.
%%   \begin{points} \item ... \end{points}  tight en-dash list for entry details.
%%
%% Internal helpers (\resume@...) are private and may change without notice.

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{resume}[2026/08/23 v1.0 Two-page academic-register resume]

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\LoadClass[11pt,a4paper]{article}

%% ---------------------------------------------------------------- packages --
\RequirePackage[T1]{fontenc}
\RequirePackage{libertinus}
\RequirePackage[protrusion,expansion,tracking,kerning,spacing]{microtype}
\microtypecontext{spacing=nonfrench}
%% Keep the spacing feature away from TS1: that encoding carries no spacing
%% list, and touching it emits a warning for every symbol font it loads.
\DeclareMicrotypeSet*[spacing]{resumetext}
  {encoding={OT1,T1,LY1}, family={rm*,sf*}}

\RequirePackage[a4paper,top=18mm,bottom=18mm,left=19mm,right=19mm,
                headheight=0pt,headsep=0pt,footskip=11mm]{geometry}
\RequirePackage{etoolbox}
\RequirePackage{tabularx}
\RequirePackage{enumitem}
\RequirePackage{titlesec}
\RequirePackage{parskip}
\RequirePackage{lastpage}
\RequirePackage{xcolor}
\RequirePackage[hidelinks,unicode]{hyperref}

%% ------------------------------------------------------------- page layout --
\setcounter{secnumdepth}{0}
\raggedbottom
\setlength{\parskip}{0.55ex plus 0.20ex minus 0.10ex}
\setlength{\parindent}{0pt}
\setlength{\emergencystretch}{1.2em}
\tolerance=1500
\hyphenpenalty=100
\clubpenalty=10000
\widowpenalty=10000

%% Strict monochrome: every rule and every glyph is black.
\definecolor{resumeink}{gray}{0}
\AtBeginDocument{\color{resumeink}}
\newcommand{\resume@rulewd}{0.4pt}

%% --------------------------------------------------------------- metadata ---
\newcommand{\resume@name}{}
\newcommand{\resume@headline}{}
\newcommand{\name}[1]{\renewcommand{\resume@name}{#1}}
\newcommand{\headline}[1]{\renewcommand{\resume@headline}{#1}}

\newcommand{\resume@contacts}{}
\newif\ifresume@firstcontact \resume@firstcontacttrue
\newcommand{\resume@contactsep}{\enspace\textbar\enspace}
%% Separator inside an entry's sub-line (organisation \textendash{} location).
%% A rule apart from the header separator: a vertical bar reads as a list
%% divider, which is right for the contact line and wrong between two facts
%% about one entry.
\newcommand{\resume@metasep}{\enspace\textendash\enspace}
\newcommand{\contact}[2][]{%
  \ifresume@firstcontact
    \resume@firstcontactfalse
  \else
    \g@addto@macro\resume@contacts{\resume@contactsep}%
  \fi
  \ifstrempty{#1}%
    {\g@addto@macro\resume@contacts{#2}}%
    {\g@addto@macro\resume@contacts{\href{#1}{#2}}}%
}

\AtBeginDocument{%
  \hypersetup{%
    pdftitle={\resume@name\ifdefempty{\resume@headline}{}{, \resume@headline}},
    pdfauthor={\resume@name},
    pdfsubject={\resume@headline},
    pdfkeywords={\resume@name; \resume@headline; curriculum vitae; resume},
    pdfcreator={pdfLaTeX with resume.cls}%
  }%
}

%% ----------------------------------------------------------- page furniture --
%% Footer on every page, first one included: name left, "page N of M" right,
%% 8pt black, separated from the body by a thin rule.
\newcommand{\resume@footfont}{\fontsize{8}{10}\selectfont}
\newcommand{\ps@resume}{%
  \let\@oddhead\@empty
  \let\@evenhead\@empty
  \def\@oddfoot{\resume@foot}%
  \let\@evenfoot\@oddfoot
}
\newcommand{\resume@foot}{%
  \parbox[t]{\textwidth}{%
    \resume@footfont
    \color{resumeink}%
    \rule{\textwidth}{\resume@rulewd}\par
    \vspace{2pt}%
    \resume@name\hfill page~\thepage\ of~\pageref*{LastPage}%
  }%
}
\pagestyle{resume}
\let\ps@plain\ps@resume

%% ---------------------------------------------------------------- headings --
%% Spaced small caps followed by a thin horizontal rule.
\newcommand{\resume@sectiontitle}[1]{\textls[60]{#1}}
\titleformat{\section}[block]
  {\normalfont\large\scshape}{}{0pt}{\resume@sectiontitle}
  [\vspace{-0.7ex}{\color{resumeink}\titlerule[\resume@rulewd]}]
\titlespacing*{\section}
  {0pt}{2.0ex plus 0.5ex minus 0.2ex}{1.0ex plus 0.2ex}

%% ------------------------------------------------------------------ header --
\newcommand{\makeheader}{%
  \begingroup
    \centering
    {\LARGE\scshape\textls[80]{\resume@name}\par}%
    \ifdefempty{\resume@headline}{}{%
      \vspace{0.8ex}{\large\itshape\resume@headline\par}}%
    \ifdefempty{\resume@contacts}{}{%
      \vspace{1.0ex}{\small\resume@contacts\par}}%
  \endgroup
  \vspace{1.0ex}%
  {\color{resumeink}\hrule height \resume@rulewd}%
  \vspace{0.4ex}%
  \par
}

%% ------------------------------------------------------------------ entries --
%% \resume@entry{left}{right}{sub-line}: left text set ragged right in a
%% flexible column, right text flush right, optional second line below.
\newcommand{\resume@entry}[3]{%
  \par\addvspace{1.0ex}%
  \noindent
  \begin{tabularx}{\linewidth}{@{}>{\raggedright\arraybackslash}X r@{}}
    #1 & #2
  \end{tabularx}%
  \par
  \ifstrempty{#3}{}{\nobreak\vspace{-0.25ex}%
    {\noindent\raggedright #3\par}}%
  \nobreak\vspace{0.15ex}%
}

\newcommand{\role}[4]{%
  \resume@entry{\textbf{#1}}{#4}{%
    \textit{#2}\ifstrempty{#3}{}{\resume@metasep #3}}%
}

\newcommand{\project}[4]{%
  \resume@entry{\textbf{#1}}{#4}{%
    \ifstrempty{#3}{}{\textit{#3}\resume@metasep}%
    \href{https://#2}{#2}}%
}

\newcommand{\record}[2]{\resume@entry{#1}{#2}{}}

%% ------------------------------------------------------------------- points --
\newlist{points}{itemize}{1}
\setlist[points]{%
  label=\textendash,
  leftmargin=1.3em,
  labelsep=0.5em,
  topsep=0.35ex plus 0.1ex,
  partopsep=0pt,
  parsep=0pt,
  itemsep=0.30ex plus 0.1ex,
  beginpenalty=10000,
  midpenalty=0,
  endpenalty=0,
  after=\vspace{0.15ex}%
}

%% ------------------------------------------------------------------- skills --
\newlength{\resume@skilllabel}
\setlength{\resume@skilllabel}{0.19\textwidth}
\newcommand{\skills}[2]{%
  \par\addvspace{0.30ex}%
  \noindent
  \begin{tabularx}{\linewidth}{@{}>{\raggedright\arraybackslash}p{\resume@skilllabel}@{\hspace{0.8em}}%
      >{\raggedright\arraybackslash}X@{}}
    \textsc{#1} & #2
  \end{tabularx}%
  \par
}

%% --------------------------------------------------------------------- note --
\newcommand{\note}[1]{%
  \par\addvspace{0.60ex}%
  \noindent{\small\raggedright #1\par}%
}

\endinput
