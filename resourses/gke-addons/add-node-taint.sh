do_not_schedule_persistent_apps_on_this_machine=`gcloud compute instances list \
            --filter="NOT (zone:${REGION}-${ZONE_POSFIX_1} OR ${REGION}-${ZONE_POSFIX_2})" \
            --format="value(name)"`

kubectl taint nodes $do_not_schedule_persistent_apps_on_this_machine need_pv=true:NoSchedule