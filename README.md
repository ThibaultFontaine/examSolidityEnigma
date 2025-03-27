# examSolidityEnigma
Ce projet contient un Smart Contract Solidity nommé Voting.sol et son fichier de déploiement Voting.js.

Nous avons un Workflow Status (WS) correspondant aux différentes étapes du processus.

Le but de ce contrat est de permettre à un administrateur (celui qui déploiera le contrat) d'enregistrer des électeurs, ouvrir des sessions de propositions et de votes, puis de déterminer la proposition gagnante.

Pour ce faire, l'administrateur doit passer aux bons états du WS aux moments requis, l'état initial étant RegisteringVoters, l'administrateur pourra enregistrer les électeurs qu'il souhaite à l'aide de la fonction addToWhitelist().

Une fois que tous les électeurs souhaités ont été enregistrés, il pourra changer l'état pour passer à la collecte des propositions avec la fonction openProposalRegistration(), qui changer le WS pour le passer à ProposalsRegistrationStarted.

Les utilisateurs enregistrés et l'administrateur pourront émettre des propositions à l'aide de la fonction registerProposal().

Une fois toutes les propositions collectées, l'admin pourra passer le WS à ProposalsRegistrationEnded avec la fonction closeProposalRegistration().

Il devra ensuite démarrer le vote à l'aide de la fonction openVotingSession() qui passera le WS à VotingSessionStarted.

Vient désormais l'étape du vote, où les utilisateurs enregistrés pourront voter à l'aide de la fonction vote().

Une fois que tous les électeurs ont voté, l'admin devra utiliser la fonction closeVotingSession(), qui passe le WS à VotingSessionEnded.

Afin d'obtenir de dépouiller les votes et de déterminer la proposition gagnante, l'admin utilisera la fonction tallyVotes(), et pour récupérer l'id de la proposition élue, il pourra utiliser la fonction getWinner(), qui retournera l'id.

Le fichier Voting.js contient les informations de déploiement, rien de spécial n'est à déclarer car le Smart Contract n'a besoin d'aucun paramètre particulier pour être déployé correctement.